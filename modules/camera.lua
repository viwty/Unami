return function(unami)
  local camera = {
    position = unami.makeCameraPosMat(0, 0, 0),
    rotation = unami.makeCameraRotMat(0, 0, 0),
    nearPlane = 1,
    farPlane = 1000,
    fov = 50
  }

  function camera:setPosition(x, y, z)
    self.position = unami.makeCameraPosMat(x, y, z)
    return self
  end

  function camera:setRotation(x, y, z, d)
    self.rotation = unami.makeCameraRotMat(x, y, z, d)
    return self
  end

  return camera
end
