const test = require("ava");
const fs = require("fs");
const path = require("path");

test("[Template] render basic template", async (t) => {
  const { transformTemplate } = require("./../../src/Engine/Engine");
  let data = await transformTemplate(
    path.join(__dirname, "source", "Template.js"),
    {}
  );
  t.deepEqual(data, {
    status: true,
    content: "<!DOCTYPE html><html><body><h1>TEST</h1></body></html>",
  });
});

test("[Template] render props template", async (t) => {
  const { transformTemplate } = require("./../../src/Engine/Engine");
  const animals = ["cat", "dog", "bird"];
  let data = await transformTemplate(
    path.join(__dirname, "source", "TemplateProps.js"),
    animals
  );
  t.deepEqual(data, {
    status: true,
    content:
      "<!DOCTYPE html><html><body><h1>cat</h1><h1>dog</h1><h1>bird</h1></body></html>",
  });
});

test("[Template] render component template", async (t) => {
  const { transformTemplate } = require("./../../src/Engine/Engine");
  let data = await transformTemplate(
    path.join(__dirname, "source", "TemplateComponent.js"),
    {}
  );
  t.deepEqual(data, {
    status: true,
    content:
      "<!DOCTYPE html><html><head><title>test</title></head><body><h1>another comp</h1></body></html>",
  });
});

test("[Template] should fail empty template", async (t) => {
  const { transformTemplate } = require("./../../src/Engine/Engine");
  let data = await transformTemplate(
    path.join(__dirname, "source", "TemplateEmpty.js"),
    {}
  );
  t.deepEqual(data, { status: false, content: undefined });
});

test("[Template] should throw error non exist template file", async (t) => {
  const { transformTemplate } = require("./../../src/Engine/Engine");
  let data = await transformTemplate(
    path.join(__dirname, "source", "TemplateNonExist.js"),
    {}
  );
  t.deepEqual(data, { status: false, content: undefined });
});
