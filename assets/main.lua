-- Frog o'clock
--
function _init()
  world.info("init XXX")
end

function _update()
    if btnp(3) and selection <3 then
        selection = selection + 1
    end
    if btnp(2) and selection > 0
        then

        selection = selection - 1
    end
end
selection = 0
function _draw()
  cls()
  color(0)
  spr(0)
  local cx, cy = 110, 68
  --circfill(cx, cy, 17, 0)
  local t = time() / 10
  local l = 20
  line(cx, cy, cx + l * sin(t), cy + l * cos(t), 0)
  t = time() / 600
  l = 10
  line(cx, cy, cx + l * sin(t), cy + l * cos(t), 0)
  print("play", 51, 41)

print("options", 46, 53)

print("quit", 51, 65)

print("credits", 46, 77)

circfill(40, 43 + 12 * selection, 1)
end
