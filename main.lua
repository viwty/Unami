local s = 1 / math.pi

local cube = {
  verts = {
    { -s, -s, -s, 1 },
    { s,  -s, -s, 1 },
    { -s, s,  -s, 1 },
    { s,  s,  -s, 1 },
    { -s, -s, s,  1 },
    { s,  -s, s,  1 },
    { -s, s,  s,  1 },
    { s,  s,  s,  1 }
  },
  indices = {
    { 1, 3, 2 }, { 3, 4, 2 },
    { 2, 4, 6 }, { 4, 8, 6 },
    { 3, 7, 4 }, { 4, 7, 8 },
    { 5, 6, 8 }, { 5, 8, 7 },
    { 1, 5, 3 }, { 3, 5, 7 },
    { 1, 2, 5 }, { 2, 6, 5 }
  }
}

local pb = require "pixelbox_lite".new(term.current())

local w, h = term.getSize()
w, h = w * 2, h * 3
local function setPixel(y, x, color)
  if not (x < 1 or x > w or y < 1 or y > h) then
    pb.CANVAS[y][x] = color
  end
end

local function drawLine(startX, startY, endX, endY, color)
  startX, startY, endX, endY = math.floor(startX), math.floor(startY), math.floor(endX), math.floor(endY)
  color = color or colors.cyan

  if startX == endX and startY == endY then
    setPixel(startY, startX, color)
  end

  local minX = math.min(startX, endX)
  local maxX, minY, maxY
  if minX == startX then
    minY, maxX, maxY = startY, endX, endY
  else
    minY, maxX, maxY = endY, startX, startY
  end

  local xDiff, yDiff = maxX - minX, maxY - minY
  if xDiff > math.abs(yDiff) then
    local y = minY
    local dy = yDiff / xDiff
    for x = minX, maxX do
      setPixel(math.floor(y + 0.5), x, color)
      y = y + dy
    end
  else
    local x, dx = minX, xDiff / yDiff
    if maxY >= minY then
      for y = minY, maxY do
        setPixel(y, math.floor(x + 0.5), color)
        x = x + dx
      end
    else
      for y = minY, maxY, -1 do
        setPixel(y, math.floor(x + 0.5), color)
        x = x - dx
      end
    end
  end
end

local function createRotX(theta)
  local sin = math.sin(theta)
  local cos = math.cos(theta)
  return {
    1, 0, 0, 0,
    0, cos, -sin, 0,
    0, sin, cos, 0,
    0, 0, 0, 1
  }
end
local function createRotY(theta)
  local sin = math.sin(theta)
  local cos = math.cos(theta)
  return {
    cos, 0, -sin, 0,
    0, 1, 0, 0,
    sin, 0, cos, 0,
    0, 0, 0, 1
  }
end
local function createRotZ(theta)
  local sinTheta = math.sin(theta)
  local cosTheta = math.cos(theta)
  return {
    cosTheta, -sinTheta, 0, 0,
    sinTheta, cosTheta, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  }
end

local function drawTriangle(v1, v2, v3)
  -- v1 -> v2 -> v3 -> v1
  drawLine(v1[1], v1[2], v2[1], v2[2])
  drawLine(v2[1], v2[2], v3[1], v3[2])
  drawLine(v3[1], v3[2], v1[1], v1[2])
end

local function worldToSS(p)
  local reverse = 1 / p[4]
  return {
    (p[1] * reverse + 1) * w / 2,
    (-p[2] * reverse + 1) * h / 2,
  }
end

local function makeScaleMat(scale)
  local x, y, z = table.unpack(scale)
  y = y or x
  z = z or x
  return {
    x, 0, 0, 0,
    0, y, 0, 0,
    0, 0, z, 0,
    0, 0, 0, 1,
  }
end

local function matmul(vec, b)
  local a1, a2, a3, a4 = table.unpack(vec)
  return {
    a1 * b[1] + a2 * b[2] + a3 * b[3] + a4 * b[4],
    a1 * b[5] + a2 * b[6] + a3 * b[7] + a4 * b[8],
    a1 * b[9] + a2 * b[10] + a3 * b[11] + a4 * b[12],
    a1 * b[13] + a2 * b[14] + a3 * b[15] + a4 * b[16]
  }
end
local function matmul4(a, b)
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

local function makeTransformMat(pos)
  return {
    1, 0, 0, pos[1],
    0, 1, 0, pos[2],
    0, 0, 1, pos[3],
    0, 0, 0, 1
  }
end

local makePerspectiveMat = require("perspective")

local function drawModel(verts, indices, rot, scale, pos)
  local rx, ry, rz = table.unpack(rot)
  local rotation_mat
  do
    local matX = createRotX(rx)
    local matY = createRotY(ry)
    local matZ = createRotZ(rz)
    rotation_mat = matmul4(matmul4(matX, matY), matZ)
  end

  local transformed = {}
  for i = 1, #verts do
    local vertice = verts[i]
    local result = { vertice[1], vertice[2], vertice[3], 1 }
    result = matmul(result, makeScaleMat(scale))
    result = matmul(result, rotation_mat)
    result = matmul(result, makeTransformMat(pos))
    transformed[i] = matmul(result, makePerspectiveMat(w/h, 1, 1000, 50))
  end

  for _, v in ipairs(indices) do
    drawTriangle(worldToSS(transformed[v[1]]), worldToSS(transformed[v[2]]), worldToSS(transformed[v[3]]))
  end
end

local function main()
  local pos = { 0, 0, 1 }

  local rot = os.epoch "UTC" / 1000
  drawModel(cube.verts, cube.indices, { rot, rot, rot }, { 1 }, pos)
  pb:render()
  pb:clear(colors.black)
end

while true do
  main()
  --sleep(.05)
  os.queueEvent"_"
  os.pullEvent"_"
end
