return function(unami)
  return function()
    while true do
      local start = os.epoch "utc"
      local zBuffer = unami.depthBuffer
      for y = 1, unami.canvH do
        zBuffer[y] = {}
      end
      unami.window.setVisible(false)

      local perspectiveMat = unami.makePerspectiveMat(
        unami.canvW / unami.canvH, unami.camera.nearPlane,
        unami.camera.farPlane, unami.camera.fov)

      unami.totalTriangles = 0
      for _, object in pairs(unami.objects) do
        object:render(perspectiveMat)
      end

      unami.main(unami.deltaTime)
      unami.pixelbox:render()
      unami.pixelbox:clear(colors.black)

      local current_time = os.epoch("utc")
      local ft = current_time - start
      unami.deltaTime = ft

      unami.frames[#unami.frames + 1] = { ft = ft, begin = start }

      for _, v in ipairs(unami.frames) do
        local t_diff = current_time - v.begin
        if t_diff > 1000 then
          table.remove(unami.frames, 1)
        else
          break
        end
      end

      if unami.showStats then
        unami.window.setCursorPos(1, unami.h - 1)
        unami.window.write(("Triangles: %d Drawn: %d"):format(unami.totalTriangles, unami.trianglesDrawn))
        unami.window.setCursorPos(1, unami.h)
        unami.window.write(("FT: %dms FPS: ~%d"):format(unami.deltaTime, #unami.frames))
      end

      unami.window.setVisible(true)
      unami.trianglesDrawn = 0

      os.queueEvent "_"
      os.pullEvent "_"
    end
  end
end
