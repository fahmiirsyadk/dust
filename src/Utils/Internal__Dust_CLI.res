@scope("Object") @val external obj_keys: 'a => array<'a> = "keys"
open Internal__Dust_Engine
open Promise

module Config = Internal__Dust_Config

let outputPath = Config.getFolderOutput()
let startPath = Config.getFolderBase()

let initialScript = () => {
  cleanOutputFolder()->then(_ => run())
}

let serverRun = () => {
  open Utils.Chokidar

  let config = {
    ignored: "**/src/**/*.js",
    ignoreInitial: true,
    awaitWriteFinish: {
      stabilityThreshold: 100,
      pollInterval: 100
    },
    depth: 99
  }

  watcher
  ->watch(startPath, config)
  ->on("add", path => {
    Js.log("adding: " ++ path)
    initialScript()->ignore
  })
  ->on("change", path => {
    Js.log("changing: " ++ path)
    update(path)
  })
}

let watcher = () => {
  open Utils.LiveServer

  server->start({root: outputPath, logLevel: 0})
  Js.log("Ready for changes")

  serverRun()
}

let exec = () => {
  let command = try {
    Node.Process.argv[2]
  } catch {
  | Invalid_argument(_) => ""
  }

  switch command {
  | "watch"
  | "w" =>
    initialScript()
    ->then(_ => {
      let _ = watcher()
      resolve()
    })
    ->catch(err => Js.log(err)->resolve)
    ->ignore
  | _ => initialScript()->ignore
  }
}
