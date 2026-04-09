-- ============================================================
-- Constants
-- ============================================================
local FPS_OPTIONS = {30, 60, 120, 144, 240, 500}
local FPS_LABELS = {"30", "60", "120", "144", "240", "Max"}
local DEFAULT_FPS = 500

-- ============================================================
-- Mod initialisation
-- ============================================================

local config = SMODS.current_mod.config
G.FPS_CAP = config.fps_cap or DEFAULT_FPS

-- ============================================================
-- FPS cap callback
-- ============================================================

G.FUNCS.set_fps = function(args)
    local key = args and args.to_val

    local fps
    if key == "Max" then
        fps = DEFAULT_FPS
    else
        local n = tonumber(key)
        for _, v in ipairs(FPS_OPTIONS) do
            if v == n then
                fps = v
                break
            end
        end
    end

    G.FPS_CAP = fps or DEFAULT_FPS
    config.fps_cap = G.FPS_CAP
end

-- ============================================================
-- Settings UI injection
-- ============================================================

local _settings_tab_orig = G.UIDEF.settings_tab

function G.UIDEF.settings_tab(tab)
    local result = _settings_tab_orig(tab)

    if tab == "Game" then
        local current = #FPS_LABELS
        for i, v in ipairs(FPS_OPTIONS) do
            if (G.FPS_CAP or DEFAULT_FPS) == v then
                current = i
                break
            end
        end

        local nodes = result.nodes
        nodes[#nodes + 1] = create_option_cycle({
            label = "FPS Cap",
            scale = 0.8,
            options = FPS_LABELS,
            opt_callback = "set_fps",
            current_option = current
        })
    end

    return result
end

-- ============================================================
-- FPS-capped run loop
-- ============================================================

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
