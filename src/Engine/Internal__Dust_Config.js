// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Path = require("path");
var JsYaml = require("js-yaml");
var Process = require("process");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");

var rootPath = Process.cwd();

var configPath = Path.join(rootPath, ".dust.yml");

var defaultFolderConfig_output = Path.join(rootPath, "dist");

var defaultFolderConfig_base = Path.join(rootPath, "src");

var defaultFolderConfig = {
  output: defaultFolderConfig_output,
  base: defaultFolderConfig_base
};

var isConfigExist = Fs.existsSync(configPath);

var dataConfig = Fs.existsSync(configPath) ? Caml_option.nullable_to_opt(JsYaml.load(Fs.readFileSync(configPath, "utf8"))) : undefined;

function getFolderBase(param) {
  var val = Belt_Option.flatMap(dataConfig, (function (data) {
          return data.base;
        }));
  if (val !== undefined) {
    return Caml_option.valFromOption(val);
  } else {
    return defaultFolderConfig_base;
  }
}

function getFolderOutput(param) {
  var val = Belt_Option.flatMap(dataConfig, (function (data) {
          return data.output;
        }));
  if (val !== undefined) {
    return Caml_option.valFromOption(val);
  } else {
    return defaultFolderConfig_output;
  }
}

var config_output = Path.join(rootPath, getFolderOutput(undefined));

var config_base = Path.join(rootPath, getFolderBase(undefined));

var config = {
  output: config_output,
  base: config_base
};

function collections(param) {
  var collections$1 = Belt_Option.flatMap(dataConfig, (function (content) {
          return content.collections;
        }));
  if (collections$1 !== undefined) {
    return Caml_option.valFromOption(collections$1);
  } else {
    return [];
  }
}

exports.rootPath = rootPath;
exports.configPath = configPath;
exports.defaultFolderConfig = defaultFolderConfig;
exports.isConfigExist = isConfigExist;
exports.dataConfig = dataConfig;
exports.getFolderBase = getFolderBase;
exports.getFolderOutput = getFolderOutput;
exports.config = config;
exports.collections = collections;
/* rootPath Not a pure module */
