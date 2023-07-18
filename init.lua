local path
local args = { ... }
if args[1] == "unami" then
  path = ("/%s/"):format(fs.getDir(args[2]))
end

package.path = path .. "?.lua;" .. path .. "modules/?.lua;" .. package.path

local unami = {}
unami.PIXELBOX = require("pixelbox_lite")

require("matrixUtils")(unami)
unami.object = require("object")(unami)
unami.camera = require("camera")(unami)
unami.loadModel = require("loadModel")(unami)
unami.keyboard = require("keyboard")(unami)
require("rendering")(unami)

function unami.isInScreen(x, y)
  return x <= unami.canvW and x >= 1 and y <= unami.canvH and y >= 1
end

unami.loaders = {}
local threads = {}

for _, file in ipairs(fs.list(fs.combine(path, "modules/loaders"))) do
  local name = file:match("^(.+)%.")
  unami.loaders[name] = require(("loaders.%s"):format(name))(unami)
end
for _, file in ipairs(fs.list(fs.combine(path, "modules/threads"))) do
  local name = file:match("^(.+)%.")
  threads[#threads+1] = require(("threads.%s"):format(name))(unami)
end

-- callbacks
function unami.init()
end

function unami.main(deltaTime)
end

function unami.run(...)
  unami.deltaTime = 0
  unami.totalTriangles = 0
  unami.trianglesDrawn = 0

  unami.disableCulling = false
  unami.showStats = false
  unami.objects = {}
  unami.frames = {}
  unami.depthBuffer = {}

  unami.w, unami.h = term.getSize()
  unami.window = window.create(term.current(), 1, 1, unami.w, unami.h)
  unami.pixelbox = unami.PIXELBOX.new(unami.window)

  unami.canvW, unami.canvH = unami.w * 2, unami.h * 3

  unami.init()

  parallel.waitForAny(table.unpack(threads))
end

return unami
