#!/usr/bin/env node

const {
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
  rmSync,
  cpSync,
  readdirSync,
  statSync,
  renameSync,
} = require("fs");
const { join, resolve, relative } = require("path");
const { execSync } = require("child_process");
const { argv } = require("process");

const args = argv.slice(2);
const environment =
  args.find((arg) => arg.startsWith("--env="))?.split("=")[1] ||
  process.env.MODE ||
  "dev";
const target =
  args.find((arg) => arg.startsWith("--target="))?.split("=")[1] ||
  process.env.TARGET ||
  "main";
const isHelpRequested = args.includes("--help");

const validEnvironments = ["prod", "dev"];
const validTargets = ["main", "random", "ranged", "helmet_only"];

if (isHelpRequested) {
  console.log(`
Usage: node build.js [--env=prod|dev] [--target=main|random|ranged|helmet_only] [--help]
--env=prod|dev                     Sets the environment (default: dev).
--target=main|random|ranged|helmet_only  Sets the build target (default: main).
--help                             Displays this help message.
`);
  process.exit(0);
}

if (!validEnvironments.includes(environment)) {
  console.error(
    `ERROR: Invalid --env value '${environment}'. Must be one of: ${validEnvironments.join(", ")}`,
  );
  process.exit(1);
}

if (!validTargets.includes(target)) {
  console.error(
    `ERROR: Invalid --target value '${target}'. Must be one of: ${validTargets.join(", ")}`,
  );
  process.exit(1);
}

const rootDirectory = resolve(__dirname, "..");
const sourceDirectory = join(rootDirectory, "src");
const temporaryBuildDirectory = join(rootDirectory, "temp_build");
const eulaFile = join(sourceDirectory, "modding_eula.txt");

function cleanBuildDirectory() {
  rmSync(temporaryBuildDirectory, { recursive: true, force: true });
  mkdirSync(temporaryBuildDirectory, { recursive: true });
}

function prepareModBuild(modName) {
  const modSourceDir = join(sourceDirectory, modName);
  if (!existsSync(modSourceDir)) {
    console.error(`ERROR: Source directory '${modSourceDir}' not found.`);
    process.exit(1);
  }

  cpSync(modSourceDir, temporaryBuildDirectory, { recursive: true });

  const manifestFile = join(temporaryBuildDirectory, "mod.manifest");
  if (!existsSync(manifestFile)) {
    console.error(`ERROR: mod.manifest not found in ${modName}!`);
    process.exit(1);
  }

  const manifestContent = readFileSync(manifestFile, "utf8");
  const modIdentifier = /<modid>(.+?)<\/modid>/.exec(manifestContent)?.[1];
  const modVersion = /<version>(.+?)<\/version>/.exec(manifestContent)?.[1];
  const displayName = /<name>(.+?)<\/name>/.exec(manifestContent)?.[1];

  if (!modIdentifier || !modVersion || !displayName) {
    console.error(
      `ERROR: Missing required fields in ${modName}'s mod.manifest`,
    );
    process.exit(1);
  }

  // Only modify HelmetOffDialog.lua for main mod
  if (modName === "main") {
    const luaFilePath = join(
      temporaryBuildDirectory,
      "Data",
      "Scripts",
      "HelmetOffDialog",
      `HelmetOffDialog.lua`,
    );

    if (existsSync(luaFilePath)) {
      const luaContent = readFileSync(luaFilePath, "utf8")
        .replace(
          /HOD_ENVIRONMENT = "([^"]+)"/,
          `HOD_ENVIRONMENT = "${environment}"`,
        )
        .replace(/MOD_NAME = "([^"]+)"/, `MOD_NAME = "${modIdentifier}"`);
      writeFileSync(luaFilePath, luaContent, "utf8");
    }
  }

  return { modIdentifier, modVersion, displayName };
}

function removeScriptsDirectory() {
  const scriptsDirectory = join(temporaryBuildDirectory, "Data", "Scripts");
  if (existsSync(scriptsDirectory)) {
    rmSync(scriptsDirectory, { recursive: true, force: true });
  }
}

function compressToPak(dataDirectory, pakOutputPath) {
  const fileList = [];

  function buildFileList(dir) {
    const items = readdirSync(dir);
    for (const item of items) {
      const fullPath = join(dir, item);
      const stat = statSync(fullPath);
      if (stat.isDirectory()) {
        buildFileList(fullPath);
      } else if (!fullPath.toLowerCase().endsWith(".pak")) {
        fileList.push(fullPath);
      }
    }
  }

  buildFileList(dataDirectory);

  if (fileList.length === 0) {
    console.error(`ERROR: No files found in '${dataDirectory}' to pack.`);
    process.exit(1);
  }

  const maxSizeBytes = 2 * 1024 * 1024 * 1024;
  let fileIdx = 0;
  let pakPartNo = 0;
  let totalFiles = fileList.length;

  while (fileIdx < totalFiles) {
    let pakPath = pakOutputPath;
    if (pakPartNo > 0) {
      pakPath = pakOutputPath.replace(".pak", `-part${pakPartNo}.pak`);
    }

    let pakSize = 0;
    const filesToPack = [];

    for (let i = fileIdx; i < totalFiles; i++) {
      const file = fileList[i];
      const fileSize = statSync(file).size;
      if (pakSize + fileSize > maxSizeBytes) break;
      pakSize += fileSize;
      const relPath = relative(dataDirectory, file);
      filesToPack.push(relPath);
      fileIdx++;
    }

    const cmd = `zip -r -9 -X "${pakPath}" ${filesToPack.map((f) => `"${f}"`).join(" ")}`;
    console.log(`Creating pak part ${pakPartNo}: ${cmd}`);
    execSync(cmd, { cwd: dataDirectory, stdio: "inherit" });

    if (!existsSync(pakPath)) {
      console.error(`ERROR: Failed to create '${pakPath}'.`);
      process.exit(1);
    }

    if (fileIdx < totalFiles) {
      if (pakPartNo === 0) {
        const newPath = pakOutputPath.replace(".pak", "-part0.pak");
        renameSync(pakPath, newPath);
      }
      pakPartNo++;
    }
  }
}

function packModData(modId) {
  const dataDirectory = join(temporaryBuildDirectory, "Data");
  const modPakFile = join(dataDirectory, `${modId}.pak`);

  if (existsSync(dataDirectory)) {
    compressToPak(dataDirectory, modPakFile);
    removeScriptsDirectory();
  }
}

function packMod(modIdentifier, modVersion) {
  const finalZipPath = join(
    rootDirectory,
    `${modIdentifier}_${modVersion}.zip`,
  );
  if (existsSync(finalZipPath)) rmSync(finalZipPath);

  const modIdDirectory = join(temporaryBuildDirectory, modIdentifier);
  mkdirSync(modIdDirectory, { recursive: true });

  // Require modding_eula.txt to exist
  if (!existsSync(eulaFile)) {
    console.error(`ERROR: Required file 'src/modding_eula.txt' not found.`);
    process.exit(1);
  }
  cpSync(eulaFile, join(temporaryBuildDirectory, "modding_eula.txt"));

  const items = readdirSync(temporaryBuildDirectory).filter(
    (item) => item !== modIdentifier,
  );
  for (const item of items) {
    const srcPath = join(temporaryBuildDirectory, item);
    const destPath = join(modIdDirectory, item);
    renameSync(srcPath, destPath);
  }

  const sevenZipBinary = join(
    rootDirectory,
    "node_modules",
    "7z-bin",
    "linux",
    "7zzs",
  );
  const sevenZipCommand = `"${sevenZipBinary}" a "${finalZipPath}" "${modIdDirectory}"`;
  console.log(`Zipping final mod: ${sevenZipCommand}`);
  execSync(sevenZipCommand);

  rmSync(temporaryBuildDirectory, { recursive: true, force: true });

  console.log(`Built ${modIdentifier} mod: ${finalZipPath}`);
  console.log(`ZIP_FILE:${finalZipPath}`);
  return finalZipPath;
}

function buildMod(modType) {
  console.log(`Building ${modType} mod...`);
  cleanBuildDirectory();
  const { modIdentifier, modVersion } = prepareModBuild(modType);

  packModData(modIdentifier);
  packMod(modIdentifier, modVersion);
}

// Execute based on target
if (environment === "prod" || environment === "dev") {
  buildMod(target);
}
