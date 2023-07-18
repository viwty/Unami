return function(aspectRatio,fov,nearPlane,farPlane)
    local fov_rad = math.rad(fov)
    local tan_half_fov = math.tan(fov_rad * 0.5)

    local A = 1 / (aspectRatio * tan_half_fov)
    local B = 1 / tan_half_fov
    local C = -(farPlane + nearPlane) / (farPlane - nearPlane)
    local D = -1
    local E = -(2 * farPlane * nearPlane) / (farPlane - nearPlane)

    return {
        A, 0, 0, 0,
        0, B, 0, 0,
        0, 0, C, D,
        0, 0, E, 0
    }
end
