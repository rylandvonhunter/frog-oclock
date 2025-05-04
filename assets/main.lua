-- Frog O'clock
--
function _init()
  world.info("init XXX")
end

function _update()
end
x = 0
y = 0

function _draw()
  cls(0)
  print("frog o'clock", x, y, 7)
  y = y + 1
  if y > 128 then
    y = 0
    x = x + 1
  end
end
