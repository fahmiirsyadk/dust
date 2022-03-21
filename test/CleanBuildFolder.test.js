const test = require("ava");
const fs = require("fs");
const extra = require('fs-extra');
const path = require("path");

const outputDir = "output"

test.before(t => {
  extra.ensureDirSync(outputDir);
  extra.writeFileSync(path.normalize(path.join(process.cwd(), outputDir, "index.html")), "<!DOCTYPE html><html><body><h1>TEST</h1></body></html>");
});

test('[Engine] should have files in output folder', t => {
  t.is(fs.readFileSync(path.normalize(path.join(process.cwd(), outputDir, "index.html")), "utf8"), "<!DOCTYPE html><html><body><h1>TEST</h1></body></html>");  
})

test('[Engine] resolve clean build folder', async t => {
  const { cleanOutputFolder } = require("./../src/Engine/Engine")
  await t.notThrowsAsync(cleanOutputFolder(path.join(process.cwd(), outputDir)))
})

test('[Engine] build folder should be empty', async t => {
  await t.false(await extra.pathExists(path.normalize(path.join(process.cwd(), outputDir, "index.html"))))
})