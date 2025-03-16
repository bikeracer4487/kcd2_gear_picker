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
  "all";
const isHelpRequested = args.includes("--help");

const validEnvironments = ["prod", "dev"];
const validTargets = ["all", "main", "random", "ranged", "helmet_only"];

if (isHelpRequested) {
  console.log(`
Usage: node build.js [--env=prod|dev] [--target=all|main|random|ranged|helmet_only] [--help]
--env=prod|dev                     Sets the environment (default: dev).
--target=all|main|random|ranged|helmet_only  Sets the build target (default: all).
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
const manifestFile = join(sourceDirectory, "mod.manifest");
const temporaryBuildDirectory = join(rootDirectory, "temp_build");
const features = ["random", "ranged", "helmet_only"];

if (!existsSync(manifestFile)) {
  console.error("ERROR: mod.manifest not found in src!");
  process.exit(1);
}

const manifestContent = readFileSync(manifestFile, "utf8");
const modIdentifier = /<modid>(.+?)<\/modid>/.exec(manifestContent)?.[1];
const modVersion = /<version>(.+?)<\/version>/.exec(manifestContent)?.[1];
const modName = /<name>(.+?)<\/name>/.exec(manifestContent)?.[1];

if (!modIdentifier || !modVersion || !modName) {
  console.error("ERROR: Missing required fields in mod.manifest.");
  process.exit(1);
}

function cleanBuildDirectory() {
  rmSync(temporaryBuildDirectory, { recursive: true, force: true });
  mkdirSync(temporaryBuildDirectory, { recursive: true });
}

function prepareMainBuild() {
  cpSync(sourceDirectory, temporaryBuildDirectory, { recursive: true });

  const luaFilePath = join(
    temporaryBuildDirectory,
    "Data",
    "Scripts",
    "HelmetOffDialog",
    `HelmetOffDialog.lua`,
  );
  if (!existsSync(luaFilePath)) {
    console.error(`ERROR: '${luaFilePath}' not found.`);
    process.exit(1);
  }

  const luaContent = readFileSync(luaFilePath, "utf8")
    .replace(
      /HOD_ENVIRONMENT = "([^"]+)"/,
      `HOD_ENVIRONMENT = "${environment}"`,
    )
    .replace(/MOD_NAME = "([^"]+)"/, `MOD_NAME = "${modName}"`);
  writeFileSync(luaFilePath, luaContent, "utf8");
}

function removeScriptsDirectory() {
  const scriptsDirectory = join(temporaryBuildDirectory, "Data", "Scripts");
  if (existsSync(scriptsDirectory)) {
    rmSync(scriptsDirectory, { recursive: true, force: true });
  }
}

function compressToPak(dataSourceDirectory, pakOutputPath) {
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

  buildFileList(dataSourceDirectory);

  if (fileList.length === 0) {
    console.error(`ERROR: No files found in '${dataSourceDirectory}' to pack.`);
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
      const relPath = relative(dataSourceDirectory, file);
      filesToPack.push(relPath);
      fileIdx++;
    }

    const cmd = `zip -r -9 -X "${pakPath}" ${filesToPack.map((f) => `"${f}"`).join(" ")}`;
    console.log(`Creating pak part ${pakPartNo}: ${cmd}`);
    execSync(cmd, { cwd: dataSourceDirectory, stdio: "inherit" });

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

function packMainData() {
  const dataDirectory = join(temporaryBuildDirectory, "Data");
  const modPakFile = join(dataDirectory, `${modIdentifier}.pak`);

  compressToPak(dataDirectory, modPakFile);
  removeScriptsDirectory();
}

function packMod(outputFileName, feature = null) {
  const finalZipPath = join(
    rootDirectory,
    `${outputFileName}_${modVersion}.zip`,
  );
  if (existsSync(finalZipPath)) rmSync(finalZipPath);

  const modDirName = feature ? `${modIdentifier}_${feature}` : modIdentifier;
  const modIdDirectory = join(temporaryBuildDirectory, modDirName);
  mkdirSync(modIdDirectory, { recursive: true });

  const items = readdirSync(temporaryBuildDirectory).filter(
    (item) => item !== modDirName,
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

  console.log(`Built ${outputFileName} mod: ${finalZipPath}`);
  console.log(`ZIP_FILE:${finalZipPath}`);
  return finalZipPath;
}

function prepareFeatureBuild(feature) {
  cleanBuildDirectory();
  mkdirSync(temporaryBuildDirectory, { recursive: true });

  // Modify manifest for feature
  const featureManifest = manifestContent
    .replace(
      `<modid>${modIdentifier}</modid>`,
      `<modid>${modIdentifier}_${feature}</modid>`,
    )
    .replace(`<name>${modName}</name>`, `<name>${modName} - ${feature}</name>`);
  writeFileSync(
    join(temporaryBuildDirectory, "mod.manifest"),
    featureManifest,
    "utf8",
  );

  // Create mod.cfg with specific content based on feature
  let modCfgContent;
  switch (feature) {
    case "random":
      modCfgContent = `helmet_off_dialog__set_random = true`;
      break;
    case "ranged":
      modCfgContent = `helmet_off_dialog__set_ranged = true`;
      break;
    case "helmet_only":
      modCfgContent = `helmet_off_dialog__set_helmet_only = true`;
      break;
    default:
      console.error(`ERROR: Unknown feature '${feature}'`);
      process.exit(1);
  }
  writeFileSync(
    join(temporaryBuildDirectory, "mod.cfg"),
    modCfgContent,
    "utf8",
  );
}

function buildMainMod() {
  console.log(`Building main mod...`);
  cleanBuildDirectory();
  prepareMainBuild();
  packMainData();
  packMod(`${modName}_main`);
}

function buildFeatureMod(feature) {
  console.log(`Building feature mod: ${feature}...`);
  prepareFeatureBuild(feature);
  packMod(`${modName}_${feature}`, feature);
}

function buildAllMods() {
  buildMainMod();
  for (const feature of features) {
    buildFeatureMod(feature);
  }
}

// Execute based on target
if (environment === "prod" || environment === "dev") {
  switch (target) {
    case "all":
      buildAllMods();
      break;
    case "main":
      buildMainMod();
      break;
    case "random":
    case "ranged":
    case "helmet_only":
      buildFeatureMod(target);
      break;
    default:
      console.error(`ERROR: Unhandled target '${target}'`);
      process.exit(1);
  }
}
