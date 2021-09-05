open Internal__Dust_Engine

let outputPath = [Node.Process.cwd(), "dist"]->Node.Path.join
let startPath = [Node.Process.cwd(), "src"]->Node.Path.join

let serverRun = () => {
  open Utils.Chokidar

  let config = {
    ignored: %re("/^.*\.(mjs)$/ig"),
    persistent: true,
    ignoreInitial: false,
  }

  watcher
  ->watch(startPath, config)
  ->on("all", _ => {
    let _ = run()
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

  Js.log(command)
  switch command {
  | "watch"
  | "w" => watcher()
  | _ => serverRun()
  }
}
