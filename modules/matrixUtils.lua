local sqrt = math.sqrt
local cos  = math.cos
local sin  = math.sin

return function(unami)
  function unami.matmul(vec, b)
    local a1, a2, a3, a4 = vec[1], vec[2], vec[3], vec[4]
    return {
      a1 * b[1] + a2 * b[2] + a3 * b[3] + a4 * b[4],
      a1 * b[5] + a2 * b[6] + a3 * b[7] + a4 * b[8],
      a1 * b[9] + a2 * b[10] + a3 * b[11] + a4 * b[12],
      a1 * b[13] + a2 * b[14] + a3 * b[15] + a4 * b[16]
    }
  end

  function unami.matmul4(a, b)
    return {
      a[1] * b[1] + a[5] * b[2] + a[9] * b[3] + a[13] * b[4],
      a[1] * b[5] + a[5] * b[6] + a[9] * b[7] + a[13] * b[8],
      a[1] * b[9] + a[5] * b[10] + a[9] * b[11] + a[13] * b[12],
      a[1] * b[13] + a[5] * b[14] + a[9] * b[15] + a[13] * b[16],
      a[2] * b[1] + a[6] * b[2] + a[10] * b[3] + a[14] * b[4],
      a[2] * b[5] + a[6] * b[6] + a[10] * b[7] + a[14] * b[8],
      a[2] * b[9] + a[6] * b[10] + a[10] * b[11] + a[14] * b[12],
      a[2] * b[13] + a[6] * b[14] + a[10] * b[15] + a[14] * b[16],
      a[3] * b[1] + a[7] * b[2] + a[11] * b[3] + a[15] * b[4],
      a[3] * b[5] + a[7] * b[6] + a[11] * b[7] + a[15] * b[8],
      a[3] * b[9] + a[7] * b[10] + a[11] * b[11] + a[15] * b[12],
      a[3] * b[13] + a[7] * b[14] + a[11] * b[15] + a[15] * b[16],
      a[4] * b[1] + a[8] * b[2] + a[12] * b[3] + a[16] * b[4],
      a[4] * b[5] + a[8] * b[6] + a[12] * b[7] + a[16] * b[8],
      a[4] * b[9] + a[8] * b[10] + a[12] * b[11] + a[16] * b[12],
      a[4] * b[13] + a[8] * b[14] + a[12] * b[15] + a[16] * b[16],
    }
  end

  function unami.makePerspectiveMat(aspectRatio, nearPlane, farPlane, fov)
    local fov_rad = math.rad(fov)
    local tan_half_fov = math.tan(fov_rad * 0.5)

    local A = 1 / (aspectRatio * tan_half_fov)
    local B = 1 / tan_half_fov
    local C = (farPlane + nearPlane) / (farPlane - nearPlane)
    local D = 1
    local E = -(2 * farPlane * nearPlane) / (farPlane - nearPlane)

    return {
      A, 0, 0, 0,
      0, B, 0, 0,
      0, 0, C, E,
      0, 0, D, 0
    }
  end

  function unami.makeQuatRotationMat(x, y, z, a)
    local lenght = sqrt(x * x + y * y + z * z)

    if lenght == 0 then
      return {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
      }
    end

    local w, s = cos(a / 2), sin(a / 2)

    local i = (x / lenght) * s
    local j = (y / lenght) * s
    local k = (z / lenght) * s

    return {
      1 - 2 * j * j - 2 * k * k, 2 * i * j - 2 * w * k, 2 * i * k + 2 * w * j, 0,
      2 * i * j + 2 * w * k, 1 - 2 * i * i - 2 * k * k, 2 * j * k - 2 * w * i, 0,
      2 * i * k - 2 * w * j, 2 * j * k + 2 * w * i, 1 - 2 * i * i - 2 * j * j, 0,
      0, 0, 0, 1
    }
  end

  unami.makeEulerRotationMat = require("eulerRotation")
  function unami.makeRotationMat(x, y, z, a)
    if a ~= nil then
      return unami.makeQuatRotationMat(x, y, z, a)
    end

    return unami.makeEulerRotationMat(x, y, z)
  end


  function unami.makePositionMat(x, y, z)
    return {
      1, 0, 0, x,
      0, 1, 0, y,
      0, 0, 1, z,
      0, 0, 0, 1
    }
  end

  function unami.makeCameraPosMat(x, y, z)
    return {
      1, 0, 0, -x,
      0, 1, 0, -y,
      0, 0, 1, -z,
      0, 0, 0, 1
    }
  end

  function unami.makeCameraRotMat(x, y, z, d)
    return unami.makeRotationMat(-x, -y, -z, d)
  end

  function unami.makeScaleMat(x, y, z)
    return {
      x, 0, 0, 0,
      0, y, 0, 0,
      0, 0, z, 0,
      0, 0, 0, 1,
    }
  end
end
