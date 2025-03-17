const nexusMods = require("./markdown");
const steamWorkshop = require("./steamWorkshop");
const bbcodenm = require("./bbcodenm");
const path = require("path");

const documentationPath = path.join(__dirname, "../../documentation");
const title = path.join(documentationPath, "title.md");
const badgesPath = path.join(documentationPath, "badges.md");
const briefInfo = path.join(documentationPath, "brief_info.md");
const showCase = path.join(documentationPath, "showcase.md");
const contentPath = path.join(documentationPath, "content.md");
const faqPath = path.join(documentationPath, "faq.md");
const changeLogs = path.join(documentationPath, "changelog.md");

nexusMods([title, badgesPath, briefInfo, showCase, contentPath]);
steamWorkshop([title, briefInfo, contentPath, faqPath, changeLogs]);
bbcodenm();
