open Internal__Dust_Engine
open Promise

let outputPath = [Node.Process.cwd(), "dist"]->Node.Path.join
let startPath = [Node.Process.cwd(), "src"]->Node.Path.join

let initialScript = () => {
  cleanOutputFolder()->then(_ => run())
}

let serverRun = () => {
  open Utils.Chokidar

  let config = {
    ignored: "**/src/**/*.mjs",
    ignoreInitial: true,
  }

  watcher
  ->watch(startPath, config)
  ->on("add", path => {
    Js.log("adding: " ++ path)
    initialScript()->ignore
  })
  ->on("change", path => {
    Js.log("changing: " ++ path)
    initialScript()->ignore
  })
}

let watcher = () => {
  open Utils.LiveServer

  server->start({root: outputPath, logLevel: 0})
  Js.log("Ready for changes")

  serverRun()
}

let exec = () => {
  let command = Node.Process.argv[2]

  switch command {
  | "watch"
  | "w" =>
    initialScript()->then(_ => watcher()->resolve)
  | _ => initialScript()->then(_ => watcher()->resolve)
  }
}
