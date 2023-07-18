return function(unami)
  return function()
    while true do
      os.pullEvent("term_resize")

      unami.w, unami.h = term.getSize()
      unami.canvW, unami.canvH = unami.w * 2, unami.h * 3

      unami.window = window.create(term.current(), 1, 1, unami.w, unami.h)
      unami.pixelbox = unami.PIXELBOX.new(unami.window)
    end
  end
end
