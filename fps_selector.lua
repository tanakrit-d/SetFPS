--- STEAMODDED HEADER
--- MOD_NAME: Set FPS
--- MOD_ID: SetFPS
--- MOD_AUTHOR: [tanakrit-d]
--- MOD_DESCRIPTION: Set target FPS without editing the Balatro files.
--- DISPLAY_NAME: Set FPS
local json = require("json")

local directory = "Mods/SetFPS"
local file_name = "config.json"
local file_path = directory .. "/" .. file_name

function SMODS.INIT.FrameRateSelector()
    local success, content = pcall(love.filesystem.read, file_path)
    if success and content then
        local success, data = pcall(json.decode, content)
        if success and data and data.fps then
            G.FPS_CAP = data.fps
        end
    else
        G.FPS_CAP = 500
    end
end

local function save()
    local content = json.encode({
        fps = G.FPS_CAP
    })
    love.filesystem.write(file_path, content)
end

G.FUNCS.set_fps = function(args)
    local fps_values = {30, 60, 120, 144, 240, 500}

    local fps_value
    if args.to_key == "Max" then
        fps_value = 500
    else
        fps_value = tonumber(args.to_key)

        if fps_value and fps_value >= 1 and fps_value <= #fps_values then
            fps_value = fps_values[fps_value]
        end
    end

    G.FPS_CAP = fps_value or 500
    save()
end

setting_tabRef = G.UIDEF.settings_tab
function G.UIDEF.settings_tab(tab)
    local setting_tab = setting_tabRef(tab)

    if tab == "Video" then
        local c1 = {
            n = G.UIT.R,
            config = {
                align = "cm",
                r = 0
            },
            nodes = {create_option_cycle({
                label = "Set FPS",
                scale = 0.8,
                options = {30, 60, 120, 144, 240, "Max"},
                opt_callback = 'set_fps',
                current_option = (function()
                    local options = {30, 60, 120, 144, 240, 500}
                    for i, val in ipairs(options) do
                        if G.FPS_CAP == val then
                            return i
                        end
                    end
                    return 6 -- Default to Max
                end)()
            })}
        }

        table.insert(setting_tab.nodes[3].nodes, #setting_tab.nodes[3].nodes + 1, c1)
    end
    return setting_tab
end

local runRef = love.run
function love.run()
    local originalRun = runRef()

    return function()
        if love.timer then
            love.timer.step()
        end

        while true do
            if love.event then
                love.event.pump()
                for name, a, b, c, d, e, f in love.event.poll() do
                    if name == "quit" then
                        if not love.quit or not love.quit() then
                            return a or 0
                        end
                    end
                    love.handlers[name](a, b, c, d, e, f)
                end
            end

            local run_time = love.timer and love.timer.getTime() or 0

            if love.timer then
                dt = love.timer.step()
            end
            dt_smooth = math.min(0.8 * dt_smooth + 0.2 * dt, 0.1)

            if love.update then
                love.update(dt_smooth)
            end

            if love.graphics and love.graphics.isActive() then
                if love.draw then
                    love.draw()
                end
                love.graphics.present()
            end

            run_time = math.min(love.timer.getTime() - run_time, 0.1)

            if G.FPS_CAP and G.FPS_CAP > 0 then
                if run_time < 1 / G.FPS_CAP then
                    love.timer.sleep(1 / G.FPS_CAP - run_time)
                end
            end
        end
    end
end
