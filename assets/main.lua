-- Frog o'clock
--

-- mode represents the main "state" of the game
-- 0 - menu
-- 1 - play
-- 2 - options
-- 3 - credits
-- 4 - quit?
-- 5 - fight
WHITE = 1
BLACK = 2
mode = 5
hp = 16
x = 13 + 3 * 128
-- x = 13
y = 48
hpmax = 16
moving = 0
-- facing directions x and y [-1, 0, 1]
fx = 0 -- -1 is left, 1 is right
fy = 1 -- -1 is up, 1 is down
function _init()
    world.info("init XXX")
    color(BLACK)
    sfx(0)
end

function _update()
    if mode == 0 then
        menu_update()
    elseif mode == 1 then
        play_update()
    elseif mode == 5 then
        fight_update()
    end
end

function _draw()
    if mode == 0 then
        menu_draw()
    elseif mode == 1 then
        play_draw()
    elseif mode == 5 then
        fight_draw()
    end
    --draw_dialog("hello", {0, 4})
end

function menu_update()
    if btnp(3) and selection < 3 then
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
end

function walkable(x, y)
    return sget(x + 8 + 128, y + 8, 5) ~= 2
end


function play_update()
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

    -- Draw the frog.
    spr({ 0, 3 }, x - 16, y - 16)
end

-- show_dialog("Hmm, a frog.", {0, 5})
-- sfx(croak_sound)
-- show_dialog("...", {1, 5})
function draw_dialog(text, portrait)
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

function play_draw()
    cls(WHITE)
    camera(128 * flr(x / 128), 0)
    spr({ 0, 2 }, -128, 0)
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

    spr({ s, 1 }, x, y, 1, 1, flip_x) -- player
    --print("t = "..flr(time()).." x, y = "..x..", "..y, 0, 0, WHITE)
    --print("s = "..s, nil, nil, WHITE)
end

fight_mode = 0
-- 0 - fight menu
-- 1 - fight
-- 2 - heal
-- 3 - flee
-- 4 - you miss the button
-- 5 - you hit the button
-- 6 - frog fights you
time_to_press = 1
function fight_draw()
    play_draw()
    rectfill(x, y, x + 16, y + 16, WHITE)
    spr({ 9, 1 }, x, y)
    local cx, cy = camera(0, 0)
    spr({ 2, 6 })
    print("bETTY", 6, 2, 1)
    rectfill(3, 8, 3 + 63 * hp / hpmax, 8 + 7, WHITE)
    spr({ 1, 7 }, 3, 8)

    if fight_mode == 0 then
    -- draw fight menu
    print("fIGHT", 8, 87, WHITE)
    print("hEAL", 8, 94, WHITE)
    print("fLEE", 8, 101, WHITE)
    circfill(3, 89 + 7 * selection, 1, WHITE)
    elseif fight_mode == 1 then
        -- fight
        camera(cx, cy)
        spr({0,8},x+8,y+2) -- sword
        spr({0,9},x+8,y-8) -- button outline

        if time() < fight_press then
            -- not ready to press
        elseif time() > fight_press and time() < fight_press + time_to_press then
           -- ready to press
           local buttons = {"z", "x"}
           print(buttons[fight_button], x+14, y-3) -- button text

        end
     elseif fight_mode == 4 then -- miss
     camera(cx, cy)
        print("miss", x+14, y -3, BLACK)
     elseif fight_mode == 5 then -- hit
     camera(cx, cy)
        print("hit", x+14, y -3,BLACK)
    end
    print("fight_mode "..fight_mode, 0,120, WHITE)
end

function fight_update()
    if fight_mode == 0 then
    if btnp(3) and selection < 2 then
        selection = selection + 1
    end
    if btnp(2) and selection > 0 then
        selection = selection - 1
    end
    if btnp(4) then
        -- selecting a menu item
        if selection == 0 then
            -- fight
            fight_mode = 1
            fight_button = rnd({1,2})
            fight_press = time() + 2 + rnd(3)
        elseif selection == 1 then
            -- heal
        elseif selection == 2 then
            -- flee
        end
    end
    elseif fight_mode == 1 then
    if time() < fight_press then
        -- not ready to press
        if btnp() then
            fight_mode = 4 -- miss
        end
    elseif time() > fight_press and time() < fight_press + time_to_press then

        -- ready to press
       local buttons = {4,5}
       if btnp(buttons[fight_button]) then
          fight_mode = 5
        elseif btnp() then
            fight_mode = 4
       end
    elseif time() > fight_press + time_to_press + 2 then
           -- time elapsed
           fight_mode = 4 -- miss
    end
    end
end
