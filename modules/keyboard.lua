return function(unami)
  local keyboard = { keys = {} }

  function keyboard.pressed(key)
    return keyboard.keys[key]
  end

  return keyboard
end
