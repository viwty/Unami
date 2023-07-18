return function(unami)
  return function()
    local keys = unami.keyboard.keys
    while true do
      local event, key, held = os.pullEvent()

      if event == "key" then
        keys[key] = { true, held }
      elseif event == "key_up" then
        keys[key] = nil
      end
    end
  end
end
