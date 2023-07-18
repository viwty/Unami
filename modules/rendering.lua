return function(unami)
  function unami.cull(a, b, c)
    local i1, i2, i3 = a[1], a[2], a[4]

    local a1 = b[1] - i1
    local a2 = b[2] - i2
    local a3 = b[4] - i3

    local b1 = c[1] - i1
    local b2 = c[2] - i2
    local b3 = c[4] - i3

    return (a2 * b3 - a3 * b2) * i1 +
        (a3 * b1 - a1 * b3) * i2 +
        (a1 * b2 - a2 * b1) * i3
  end

  local function setPixel(y, x, color)
    if x >= 1 and x <= unami.canvW and y >= 1 and y <= unami.canvH then
      unami.pixelbox.CANVAS[y][x] = color
    end
  end

  function unami.worldToSS(p)
    local reverse = 1 / p[4]
    return {
      (p[1] * reverse + 1) * unami.canvW / 2,
      (-p[2] * reverse + 1) * unami.canvH / 2,
      reverse,
      p[4]
    }
  end

  local function slope(x1, y1, x2, y2)
    return (y2 - y1) / (x2 - x1)
  end

  local function getBaryCoord(x, y, p1, p2, p3)
    local div = ((p2[2] - p3[2]) * (p1[1] - p3[1]) + (p3[1] - p2[1]) * (p1[2] - p3[2]))
    local ba = ((p2[2] - p3[2]) * (x - p3[1]) + (p3[1] - p2[1]) * (y - p3[2])) / div
    local bb = ((p3[2] - p1[2]) * (x - p3[1]) + (p1[1] - p3[1]) * (y - p3[2])) / div

    return { ba, bb, 1 - ba - bb }
  end

  local NEAR_CUT = .2
  function unami.drawTriangle(p1, p2, p3, color)
    if p1[4] <= NEAR_CUT or p2[4] <= NEAR_CUT or p3[4] <= NEAR_CUT then
      return
    end

    if p1[2] > p3[2] then p1, p3 = p3, p1 end
    if p1[2] > p2[2] then p1, p2 = p2, p1 end
    if p2[2] > p3[2] then p2, p3 = p3, p2 end

    local split_alpha = (p2[2] - p1[2]) / (p3[2] - p1[2])
    local split_x = (1 - split_alpha) * p1[1] + split_alpha * p3[1]
    local split_y = (1 - split_alpha) * p1[2] + split_alpha * p3[2]
    local split_z = (1 - split_alpha) * p1[3] + split_alpha * p3[3]

    local split_point = { split_x, split_y, split_z }
    local left_point, right_point = p2, split_point
    if left_point[1] > right_point[1] then
      left_point, right_point = right_point, left_point
    end

    local delta_left_top     = 1 / slope(p1[1], p1[2], left_point[1], left_point[2])
    local delta_right_top    = 1 / slope(p1[1], p1[2], right_point[1], right_point[2])

    local delta_left_bottom  = 1 / slope(p3[1], p3[2], left_point[1], left_point[2])
    local delta_right_bottom = 1 / slope(p3[1], p3[2], right_point[1], right_point[2])

    -- flat bottom
    local subpixel_top       = math.floor(p1[2] + 0.5) + 0.5 - p1[2]
    local subpixel_bottom    = math.floor(p2[2] + 0.5) + 0.5 - left_point[2]

    local zBuffer            = unami.depthBuffer
    local x_left, x_right    = p1[1] + delta_left_top * subpixel_top, p1[1] + delta_right_top * subpixel_top
    if delta_left_top then
      for y = math.floor(p1[2] + 0.5), math.floor(p2[2] + 0.5) - 1 do
        if unami.isInScreen(1, y) then
          for x = math.ceil(x_left - 0.5), math.ceil(x_right - 0.5) - 1 do
            local baryCoords = getBaryCoord(x, y, left_point, right_point, p3)
            local z = (left_point[3] * baryCoords[1]) + (right_point[3] * baryCoords[2]) + (p3[3] * baryCoords[3])
            if zBuffer[y][x] == nil or zBuffer[y][x] <= z then
              zBuffer[y][x] = z
              setPixel(y, x, color)
            end
          end
        end

        x_left, x_right = x_left + delta_left_top, x_right + delta_right_top
      end
    end


    -- flat top
    x_left, x_right = left_point[1] + delta_left_bottom * subpixel_bottom,
        right_point[1] + delta_right_bottom * subpixel_bottom
    if delta_left_bottom then
      for y = math.floor(p2[2] + 0.5), math.ceil(p3[2] - 0.5) do
        if unami.isInScreen(1, y) then
          for x = math.ceil(x_left - 0.5), math.ceil(x_right - 0.5) - 1 do
            local baryCoords = getBaryCoord(x, y, p1, left_point, right_point)
            local z = (p1[3] * baryCoords[1]) + (left_point[3] * baryCoords[2]) + (right_point[3] * baryCoords[3])
            if zBuffer[y][x] == nil or zBuffer[y][x] <= z then
              zBuffer[y][x] = z
              setPixel(y, x, color)
            end
          end
        end

        x_left, x_right = x_left + delta_left_bottom, x_right + delta_right_bottom
      end
    end
  end
end
