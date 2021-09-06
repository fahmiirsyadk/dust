open Internal__Dust_Engine

let outputPath = [Node.Process.cwd(), "dist"]->Node.Path.join
let startPath = [Node.Process.cwd(), "src"]->Node.Path.join

let initialScript = () => {
  cleanOutputFolder()
  run()
}

let serverRun = () => {
  open Utils.Chokidar

  let config = {
    ignored: "src/**/*.mjs",
    persistent: true,
    ignoreInitial: true,
  }

  watcher
  ->watch(startPath, config)
  ->on("all", (_, path) => {
    Js.log(path)
    cleanOutputFolder()
    run()
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
  | "w" => {
      initialScript()
      watcher()
    }
  | _ => {
      initialScript()
      serverRun()
    }
  }
}
