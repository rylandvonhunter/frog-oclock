-- Frog o'clock
--

-- mode represents the main "state" of the game
-- 0 - menu
-- 1 - play
-- 2 - options
-- 3 - credits
-- 4 - quit?
mode = 0
function _init()
  world.info("init XXX")
end
function _update()
  if mode == 0 then
      menu_update()
  elseif mode == 1 then
      play_update()
  end
end
function _draw()
    -- draw_dialog("Hello")
    if mode == 0 then
        menu_draw()
    elseif mode == 1 then
        play_draw()
    end
end

function menu_update()
    if btnp(3) and selection <3 then
        selection = selection + 1
    end
    if btnp(2) and selection > 0 then
        selection = selection - 1
    end
    if btnp(4) then
       -- selecting a menu item
       if selection == 0 then
          mode = 1
       end
    end
end
selection = 0
function menu_draw()
  cls() -- clear screen
  color(0) -- set color to black
  spr(0) -- draw the title sprite
  local cx, cy = 110, 68 -- circle center
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

x = 13 + 3 * 128
y = 48
moving = 0
-- facing directions x and y [-1, 0, 1]
fx = 0 -- -1 is left, 1 is right
fy = 1 -- -1 is up, 1 is down
function play_update()
    moving = 0
    if btn(3) then
        -- down
        y = y + 1
        moving = 1
        fy = 1
        fx = 0
    end
    if btn(2) then
        -- up
        y= y -1
        moving = 1
        fy = -1
        fx = 0
    end
    if btn(1) then
        -- right
        x = x + 1
        moving = 1
        fy = 0
        fx = 1
    end
    if btn(0) then
        -- left
        x= x -1
        moving = 1
        fy = 0
        fx = -1
    end
end

function draw_frog_pond(x,y)
    circfill( x, y, 20, 0 )
    spr({0,3}, x - 16, y - 16)
end

-- show_dialog("Hmm, a frog.", {0, 5})
-- sfx(croak_sound)
-- show_dialog("...", {1, 5})
function draw_dialog(text, portrait)
    local cx, cy = camera()
    rectfill(cx, cy + 82, cx + 128, cy + 128, 0)
    local w = 2 -- width
    rectfill(cx + w, cy + 82 + w, cx + 128 - w, cy + 128 - w, 7)
    if portrait then

    end

end

function play_draw()
  cls(7)
   camera(128 * flr(x / 128), 0)
   spr({0,2}, -128, 0)
   -- 96, 59
   draw_frog_pond(82 + 3 * 128, 58)
   -- +9 for right walking sprites
   local s = flr((x + y) * moving / 5) % 4
   if fy < 0 then
       s = s + 4
   end
   local flip_x = false
   if fx ~= 0 then
       s = s + 9
       if fx == -1 then
         flip_x = true
       end
   end

   spr({s,1}, x, y, 1, 1, flip_x) -- player
   print("t = "..flr(time()).." x, y = "..x..", "..y, 0, 0, 7)
   print("s = "..s, nil, nil, 7)
end
