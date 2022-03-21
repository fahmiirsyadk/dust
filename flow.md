# Hook
- beforeBuild()
- afterBuild()

# Build
[beforeBuild] (execute callback)
-> [collect pages] (Parallel Task)
-> [each page] 
-> [parseTemplate] 
-> [transformPage]
-> (check status, if false return nothing otherwise go next step)
-> (remove previous build on output folder)
-> (writeFile and place it on Dist folder)
-> [afterBuild]
-> (return ignore)

[collect collection]



# Metadata
- pages:
  - originalPath in `/pages`
- Each page:
  - originalPath in `/pages`
- ParseTemplate:
  - { status: bool, content: Option<string> }
