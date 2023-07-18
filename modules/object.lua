local object = {}

return function(unami)
  function object:setPosition(x, y, z)
    self.position = unami.makePositionMat(x, y, z)
    return self
  end

  function object:setRotation(x, y, z, d)
    self.rotation = unami.makeRotationMat(x, y, z, d)
    return self
  end

  function object:setScale(x, y, z)
    self.scale = unami.makeScaleMat(x, y, z)
    return self
  end

  function object:render(perspectiveMat)
    local transformed = {}
    for i = 1, #self.verts do
      local vertice = self.verts[i]
      local result = { vertice[1], vertice[2], vertice[3], 1, vertice[5] }
      result = unami.matmul(result, self.scale)
      result = unami.matmul(result, self.rotation)
      result = unami.matmul(result, self.position)
      result = unami.matmul(result, unami.camera.position)
      result = unami.matmul(result, unami.camera.rotation)
      transformed[i] = unami.matmul(result, perspectiveMat)
    end

    local texture = self.texture
    for i, v in ipairs(self.tris) do
      unami.totalTriangles = unami.totalTriangles + 1
      local cull = unami.cull(
        transformed[v[1]],
        transformed[v[2]],
        transformed[v[3]])
      if cull < 0 or unami.disableCulling then
        unami.trianglesDrawn = unami.trianglesDrawn + 1
        unami.drawTriangle(
          unami.worldToSS(transformed[v[1]]),
          unami.worldToSS(transformed[v[2]]),
          unami.worldToSS(transformed[v[3]]),
          2^((i%15)+1))
      end
    end
  end

  local mt = { __index = object }

  return {
    new = function(model)
      local obj = setmetatable({
        verts = model.verts,
        tris = model.tris,
        uvs = model.uvs,
        uv_idx = model.uv_idx,
        texture = model.texture,
        position = unami.makePositionMat(0, 0, 0),
        rotation = unami.makeRotationMat(0, 0, 0),
        scale = unami.makeScaleMat(1, 1, 1)
      }, mt)
      unami.objects[#unami.objects + 1] = obj
      return obj
    end
  }
end
