local FPS_OPTIONS = {30, 60, 120, 144, 240, 500}
local FPS_LABELS = {"30", "60", "120", "144", "240", "Max"}
local DEFAULT_FPS = 500

local mod = SMODS.current_mod
local config = mod.config

local function get_fps_index(fps)
    for i, value in ipairs(FPS_OPTIONS) do
        if value == fps then
            return i
        end
    end

    return #FPS_OPTIONS
end

local current_index = get_fps_index(config.fps_cap)
config.fps_cap = FPS_OPTIONS[current_index]
G.FPS_CAP = config.fps_cap

G.FUNCS.fps_set_cap = function(args)
    local index = args and args.cycle_config and args.cycle_config.current_option
    local fps = FPS_OPTIONS[index] or DEFAULT_FPS

    config.fps_cap = fps
    G.FPS_CAP = fps
end

mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR
        },
        nodes = {
            create_option_cycle({
                label = "FPS Cap",
                scale = 0.8,
                options = FPS_LABELS,
                opt_callback = "fps_set_cap",
                current_option = get_fps_index(config.fps_cap)
            })
        }
    }
end

local _run_orig = love.run

function love.run()
    local original_loop = _run_orig()

    return function()
        local frame_start = love.timer and love.timer.getTime() or 0

        local result = original_loop()

        if G.FPS_CAP and G.FPS_CAP > 0 and love.timer then
            local elapsed = math.min(love.timer.getTime() - frame_start, 0.1)
            local frame_time = 1 / G.FPS_CAP
            if elapsed < frame_time then
                love.timer.sleep(frame_time - elapsed)
            end
        end

        return result
    end
end
