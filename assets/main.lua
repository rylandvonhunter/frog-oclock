-- Frog o'clock
--

WHITE = 1
BLACK = 2
hp = 16
x = 13 + 3 * 128
-- x = 13
y = 48
hpmax = 16
moving = 0
-- facing directions x and y [-1, 0, 1]
fx = 0 -- -1 is left, 1 is right
fy = 1 -- -1 is up, 1 is down
frame = 0

function _init()
    world.info("init XXX")
    camera(0,0)
    color(BLACK)
    --sfx(0)
    game = cocreate(frog_game)
end

function frog_game()
  main_menu()
end

function _update()
  assert(coresume(game))
  -- local ok, result = coresume(game)
  -- if not ok then
  --   world.info(result)
  -- end
    frame = frame + 1
end

-- We're going to do everything in _update() now.
function _draw()
end

function main_menu()
  local selection = 0
  while true do
    cls(BLACK)             -- clear screen
    color(BLACK)           -- set color to black
    spr(0)                 -- draw the title sprite
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
    if btnp(3) and selection < 3 then
        selection = selection + 1
    end
    if btnp(2) and selection > 0 then
        selection = selection - 1
    end
    if btnp(4) then
        -- selecting a menu item
        if selection == 0 then
          play()
            -- mode = 1
        end
    end
    yield()
  end
end

function walkable(x, y)
    if y > 0 and y < 128 then
        -- cavern
        return sget(x + 8 + 128, y + 8, 5) ~= 2
    elseif y >= -256 and y <= -128 then
        -- betty's room
        return sget(x + 8, y + 8 + 256, 12) ~= 2
    else
        return true
    end
end

function draw_world()
    cls(WHITE)
    camera(128 * flr(x / 128), 128 * flr(y / 128))
    -- cavern
    spr({ 0, 2 }, -128, 0)
    -- bettys house inside
    spr ({0,11},0,-256)
    -- shop interior
    spr({ 0, 15 }, 128, -256)
    -- betty's house outside
    spr({0,13},0, 128)
    -- shop
    spr({0,14},128,128)

    draw_frog_pond(frog.x + 16, frog.y + 16)
    -- Draw the frog.
    spr({ 0, 3 }, frog.x, frog.y)
end

function draw_player()
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

    spr({ s, 1 }, x, y, 1, 1, flip_x) -- player
end

function play()
  while true do
    draw_world()
    draw_player()
    moving = 0

    if btn(3) and walkable(x, y + 1) then
        -- down
        y = y + 1
        moving = 1
        fy = 1
        fx = 0
    end
    if btn(2) and walkable(x, y - 1) then
        -- up
        y = y - 1
        moving = 1
        fy = -1
        fx = 0
    end
    if btn(1) and walkable(x + 1, y) then
        -- right
        x = x + 1
        moving = 1
        fy = 0
        fx = 1
    end
    if btn(0) and walkable(x - 1, y) then
        -- left
        x = x - 1
        moving = 1
        fy = 0
        fx = -1
    end

    if distance(x,y, frog.x, frog.y) < 40 then
      draw_dialog("RIBBIT", {4, 4})
      wait_for_btnp()
      draw_dialog("wHAT A CUTE LITTLE FROG", {0, 4})
      wait_for_btnp()
      draw_dialog("*croak*", {4, 4})
      -- TODO: start wild music here?
      wait_for_btnp()
      fight()
      -- Put ourselves back to bed, facing down.
      fx = 0
      fy = 1
      x =4
      y =6-256
    elseif distance(x,y,64,-128) < 30 then
        -- leave betty's house
        x = 87
        y = 85 + 128
    end

    yield()
  end
end

-- Return distance between (x1, y1) and (x2, y2)
function distance(x1,y1,x2,y2)
  return sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))
end

-- wait for the given number of seconds
function wait(seconds)
  local start = time()
  while time() - start < seconds do
    yield()
  end
end

-- wait for any button or the given button
--
-- If a timeout is given it will only wait that long returning false if no key
-- was pressed.
function wait_for_btnp(button, timeout)
  local start = time()
  yield()
  while true do
    if btnp(button) then
      return true
    end
    if timeout and time() - start > timeout then
      return false
    end
    yield()
  end
end

ripple = nil
function draw_frog_pond(x, y)
    -- Draw a pond.
    circfill(x, y, 20, BLACK)

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
        if rnd() < 0.10 then
            ripple = { x = x + 18 * rnd(), y = y + 18 * rnd(), r = 0 }
        end
    end
end

-- show_dialog("Hmm, a frog.", {0, 5})
-- sfx(croak_sound)
-- show_dialog("...", {1, 5})
function draw_dialog(text, portrait)
  world.info("draw_dialog")
    -- Let's move the camera to its default position, so we can draw the UI
    -- in screen coordinates from 0,0 to 128,128.
    local cx, cy = camera(0, 0)
    local w = 2       -- width of border
    local height = 36 -- dialog height
    rectfill(0, 128 - height,
        128, 128,
        BLACK)
    rectfill(w, 128 - height + w,
        128 - w, 128 - w,
        WHITE)
    if portrait then
        -- spr(portrait, 128 - w - 16, 128 - w - 16)
        -- We want to draw it twice as big.
        sspr(portrait[1] * 16, 0, 16, 16,
            128 - w - 32, 128 - w - 32,
            32, 32, nil, nil, portrait[2])
    end
    print(text, 2 * w, 128 - height + 2 * w)
    -- Put the camera back.
    camera(cx, cy)
end

frog = {
    x = 82 + 3 * 128 - 16,
    y = 58 - 16
}

function fight_menu()
  local selection = 0

  -- draw fight menu
  print("fIGHT", 8, 87, WHITE)
  print("hEAL", 8, 94, WHITE)
  print("fLEE", 8, 101, WHITE)

  local dot = circfill(3, 89 + 7 * selection, 1, WHITE):retain(0.1)
  while true do
    if btnp(3) and selection < 2 then
        selection = selection + 1
    end
    if btnp(2) and selection > 0 then
        selection = selection - 1
    end
    -- set the dot position
    dot:pos(nil, 89 + 7 * selection)
    if btnp(4) then
      dot:despawn()
      return selection
    end
    yield()
  end
end

function frog_attack()
  local start = time()
  local ball = spr({0,10}, frog.x, frog.y):retain(0.5)
  while true do
    local t = time() - start
    local bx = frog.x + (x - frog.x) * t
    ball:pos(bx, frog.y + 20 * sin(t/2))
    if t > 1 then
      ball:despawn()

      local damage = flr(rnd(3)+2)
      hp = hp - damage
      wait(1)
      return
    end
    yield()
  end
end

function fight()
  while true do
    cls()
    draw_world()
    -- Make player face right before we draw them.
    fx = 1
    fy = 0
    draw_player()
    rectfill(x, y, x + 16, y + 16, WHITE)
    spr({ 9, 1 }, x, y)
    local cx, cy = camera(0, 0)
    spr({ 2, 6 })
    print("bETTY", 6, 2, 1)
    rectfill(3, 8, 3 + 63 * hp / hpmax, 8 + 7, WHITE)
    spr({ 1, 7 }, 3, 8)
    local selection = fight_menu()
    if selection == 0 then -- fight
      -- fight_mode = 1
        camera(cx, cy)
        spr({0,8},x+8,y+2) -- sword
        spr({0,9},x+8,y-8) -- button outline
        -- not ready to press
        if wait_for_btnp(nil, rnd(2)) then
          print("miss", x+14, y -3, BLACK)
          wait(1)
        else
           -- ready to press
           local buttons_names = {"z", "x"}
           local buttons = {4,5}
           local fight_button = ceil(rnd(2))
           print(buttons_names[fight_button], x+14, y-3) -- button text
           if wait_for_btnp(buttons[fight_button], 1.0) then
            print("hit", x+14, y - 3, BLACK)
           else
            print("miss", x+14, y -3, BLACK)
           end
            wait(1)
        end
        frog_attack()
        if hp < 1 then
          return false
        end
    end
    yield()
  end
end
