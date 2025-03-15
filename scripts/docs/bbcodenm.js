const path = require("path");
const { execSync } = require("child_process");

const rootDir = path.join(__dirname, "../..");
const documentationDir = path.join(rootDir, "documentation");

function bbcode() {
  const readmeFile = path.join(rootDir, "readme.md");
  const readmeFileBbcode = path.join(rootDir, "documentation", "readme.bbcode");
  execSync(`markdown_to_bbcodenm -i ${readmeFile} > ${readmeFileBbcode}`);

  const faqFile = path.join(documentationDir, "faq.md");
  const faqFileBbcode = path.join(documentationDir, "faq.bbcode");
  execSync(`markdown_to_bbcodenm -i ${faqFile} > ${faqFileBbcode}`);

  const ideasFile = path.join(documentationDir, "ideas.md");
  const ideasFileBbcode = path.join(documentationDir, "ideas.bbcode");
  execSync(`markdown_to_bbcodenm -i ${ideasFile} > ${ideasFileBbcode}`);

  const steamReadmeFile = path.join(
    documentationDir,
    "readme_steam_workshop.md",
  );
  const steamReadmeFileBbcode = path.join(
    documentationDir,
    "readme_steam_workshop.bbcode",
  );
  execSync(
    `markdown_to_bbcodesteam -i ${steamReadmeFile} -o ${steamReadmeFileBbcode}`,
  );
}

module.exports = bbcode;

bbcode();
