const test = require("ava");
const fs = require("fs");
const path = require("path");
const extra = require("fs-extra");

test("[Template] render basic template", async (t) => {
  const { parseTemplate } = require("./../../src/Engine/Engine");
  let data = await parseTemplate(
    path.join(__dirname, "source", "Template.js"),
    {}
  );
  t.deepEqual(data, {
    content: "<!DOCTYPE html><html><body><h1>TEST</h1></body></html>",
  });
});

test("[Template] render props template", async (t) => {
  const { parseTemplate } = require("./../../src/Engine/Engine");
  const animals = ["cat", "dog", "bird"];
  let data = await parseTemplate(
    path.join(__dirname, "source", "TemplateProps.js"),
    animals
  );
  t.deepEqual(data, {
    content:
      "<!DOCTYPE html><html><body><h1>cat</h1><h1>dog</h1><h1>bird</h1></body></html>",
  });
});

test("[Template] render component template", async (t) => {
  const { parseTemplate } = require("./../../src/Engine/Engine");
  let data = await parseTemplate(
    path.join(__dirname, "source", "TemplateComponent.js"),
    {}
  );
  t.deepEqual(data, {
    content:
      "<!DOCTYPE html><html><head><title>test</title></head><body><h1>another comp</h1></body></html>",
  });
});

test("[Template] should fail empty template", async (t) => {
  const { parseTemplate } = require("./../../src/Engine/Engine");
  let data = await parseTemplate(
    path.join(__dirname, "source", "TemplateEmpty.js"),
    {}
  );
  t.deepEqual(data, { content: undefined });
});

test("[Template] should throw error non exist template file", async (t) => {
  const { parseTemplate } = require("./../../src/Engine/Engine");
  let data = await parseTemplate(
    path.join(__dirname, "source", "TemplateNonExist.js"),
    {}
  );
  t.deepEqual(data, { content: undefined });
});

test("[Template] Transform template to html", async (t) => {
  const {
    Transform: { page },
  } = require("./../../src/Engine/Engine");
  await t.notThrowsAsync(
    page(path.join(__dirname, "source", "Template.js"), {})
  );
  t.is(
    fs.readFileSync(
      path.join(process.cwd(), "dist", "Template", "index.html"),
      "utf8"
    ),
    "<!DOCTYPE html><html><body><h1>TEST</h1></body></html>"
  );
});

test("[Template] Transform template 404 to html", async (t) => {
  const {
    Transform: { page },
  } = require("./../../src/Engine/Engine");
  await t.notThrowsAsync(page(path.join(__dirname, "source", "404.js"), {}));
  t.is(
    fs.readFileSync(
      path.join(process.cwd(), "dist", "404.html"),
      "utf8"
    ),
    "<!DOCTYPE html><html><body><h1>404</h1></body></html>"
  );
});

test.after("cleanup", () => {
  extra.removeSync(path.join(process.cwd(), "dist"));
})
