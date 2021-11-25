<div align="center">

# Dust

![Dust logo as desert emoji](https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/apple/285/desert_1f3dc-fe0f.png)

small static site generator with ( **ocaml 🐫** / **reasonml** / **rescript** ) syntax
</div>

---

### Table Of Contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Documentation](#documentation)
  * [Basics](#docs-basics)
  * [Working with data](#docs-data)
  * [Configuration](#docs-configuration)
  * [Advanced & API](#docs-adv-api)


# Introduction
Dust is a static site generator for `hardcore ppl`, that use **ocaml 🐫** syntax as the template engine and transform it into static **HTML**; inspired from [Halogen](https://github.com/purescript-halogen/purescript-halogen). Dust use **Rescript** as _compiler_, so you can use **Rescript** API like **Js**, **Belt**, **Array**, **List** also **Node** module & etc.

Benefit using Dust:

* **Functional approach, Safe & Expressive.** If you write wrong code, it will give you _nice feedback_ (thanks Rescript). Also you can use looping, pattern matching or whatever like normal ocaml code (except u can't use ocaml packages, ofc).

# Installation
### Initialize project
```bash
# create project folder
mkdir yourapp
cd yourapp

# init with npm
npm init -y

# init with yarn
yarn init -y
```

### Install Dependencies
```bash
# using npm
npm install rescript --save-dev
npm install @fahmiirsyadk/dust

# using yarn
yarn add -D rescript
yarn add @fahmiirsyadk/dust
```

### Configuration

#### Configure bsconfig.json
Create a file named bsconfig.json in your project folder & paste code below, also change the name
```json
{
  "name": "yourapp",
  "version": "0.0.1",
  "sources": [
    {
      "dir": "src",
      "subdirs": true
    }
  ],
  "package-specs": {
    "module": "commonjs",
    "in-source": true
  },
  "suffix": ".js",
  "bs-dependencies": [
    "@fahmiirsyadk/dust"
  ],
  "warnings": {
    "error": "+101"
  }
}
```

### Configure run scripts
Open package.json & add script below to run dust
```json
"scripts": {
  "dev": "dust w", 
  "build": "dust",
  "re:dev": "rescript build -w",
  "re:clean": "rescript clean",
  "re:build": "rescript",
  "export": "rescript && dust"
}
```

# Documentation

