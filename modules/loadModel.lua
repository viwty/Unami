return function(unami)
  return function(path, texPath)
    path = fs.combine(shell.dir(), path)
    if not fs.exists(path) then
      error(("File %s not found!"):format(path))
    end

    local extension = path:match("%.(.+)$")

    local texture = {}
    for y = 1, 100 do
      texture[y] = {}
      for x = 1, 100 do
        texture[y][x] = 2 ^ math.random(0, 7)
      end
    end
    local model = unami.loaders[extension](path)
    model.texture = texture
    return model
  end
end
