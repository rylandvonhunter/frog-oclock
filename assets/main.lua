-- Frog o'clock
--

-- mode represents the main "state" of the game
-- 0 - menu
-- 1 - play
-- 2 - options
-- 3 - credits
-- 4 - quit?
WHITE = 1
BLACK = 2
mode = 0
function _init()
  world.info("init XXX")
  color(BLACK)
end
function _update()
  if mode == 0 then
      menu_update()
  elseif mode == 1 then
      play_update()
  end
end
function _draw()
    if mode == 0 then
        menu_draw()
    elseif mode == 1 then
        play_draw()
    end
    -- draw_dialog("Hello")
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
  cls(BLACK) -- clear screen
  color(BLACK) -- set color to black
  spr(0) -- draw the title sprite
  local cx, cy = 110, 68 -- circle center
  --circfill(cx, cy, 17, 0)
  local t = time() / 10
  local l = 20
  line(cx, cy, cx + l * sin(t), cy + l * cos(t), BLACK)
  t = time() / 600
  l = 10
  line(cx, cy, cx + l * sin(t), cy + l * cos(t), BLACK)
  print("play", 51, 41)
  print("options", 46, 53)
  print("quit", 51, 65)
  print("credits", 46, 77)
  circfill(40, 43 + 12 * selection, 1)
end

x = 13 + 3 * 128
-- x = 13
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

ripple = nil
function draw_frog_pond(x,y)
    -- Draw a pond.
    circfill( x, y, 20, BLACK)

    -- Maybe draw a ripple.
    if ripple then
      -- If a ripple exists, we draw it and
      -- increase its size slightly.
      circ(ripple.x, ripple.y, ripple.r, WHITE)
      ripple.r = ripple.r + 0.09
      if ripple.r > 3 then
        -- Once the ripple gets too big, we delete it.
        ripple = nil
      end
    else
      -- If there's no ripple, there's a 10% chance per frame
      -- we'll start a random one.
      if rnd() < 0.1 then
        ripple = { x = x + 18 * rnd(), y = y + 18 * rnd(), r = 0 }
      end
    end

    -- draw the frog
    spr({0,3}, x - 16, y - 16)
end

-- show_dialog("Hmm, a frog.", {0, 5})
-- sfx(croak_sound)
-- show_dialog("...", {1, 5})
function draw_dialog(text, portrait)
  -- Let's move the camera to its default position, so we can draw the UI
  -- anywhere from 0,0 to 128,128.
  local cx, cy = camera(0, 0)
  rectfill(0, 82, 128, 128, BLACK)
  local w = 2 -- width
  rectfill(w, 82 + w, 128 - w, 128 - w, WHITE)
  if portrait then

  end
  -- Put the camera back.
  camera(cx,cy)
end

function play_draw()
  cls(WHITE)
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
   print("t = "..flr(time()).." x, y = "..x..", "..y, 0, 0, WHITE)
   print("s = "..s, nil, nil, WHITE)

end
