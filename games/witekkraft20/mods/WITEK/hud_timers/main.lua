timers = {}

local config = modlib.mod.configuration()

modlib.table.add_all(getfenv(1), config)

minetest.register_on_joinplayer(
    function(player)
        timers[player:get_player_name()] = {}
    end
)

minetest.register_on_leaveplayer(
    function(player)
        timers[player:get_player_name()] = {}
    end
)

local timer = 0

minetest.register_globalstep(
    function(dtime)
        timer = timer + dtime
        if timer >= globalstep then
            for playername, timers in pairs(timers) do
                maintain_timers(timers, timer, minetest.get_player_by_name(playername))
            end
            timer = 0
        end
    end
)

function trigger_event(playername, event_name)
    for _, timer in ipairs(timers[playername]) do
        if timer.on_event and timer.on_event[event_name] then
            timer.on_event[event_name](playername, timer)
        end
    end
end

function add_timer(playername, timer_definition)
    local player = minetest.get_player_by_name(playername)
    local offset = 0
    offset = #(timers[playername])
    if (offset == hud_timers_max) then
        return false
    end
    offset = offset * -20
    local bg_id =
        player:hud_add(
        {
            hud_elem_type = "statbar",
            position = hud_pos,
            size = nil, -- intentionally set to nil
            text = "hudbars_bar_background.png",
            number = 2,
            alignment = {x = 1, y = 1},
            offset = {x = 0, y = offset}
        }
    )
    local bar_id =
        player:hud_add(
        {
            hud_elem_type = "statbar",
            position = hud_pos,
            size = nil, -- intentionally set to nil
            text = "hud_timers_bar_timeout.png^[colorize:#" .. (timer_definition.color or "000000"),
            number = 160,
            alignment = {x = 1, y = 1},
            offset = {x = 1, y = offset + 1}
        }
    )
    local text_id =
        player:hud_add(
        {
            hud_elem_type = "text",
            position = hud_pos,
            size = nil,
            text = string.format(
                format,
                timer_definition.name,
                modlib.number.round(timer_definition.duration, timer_definition.rounding_steps)
            ),
            number = 0xFFFFFF,
            alignment = {x = 1, y = 1},
            offset = {x = 2, y = offset}
        }
    )

    local timer = {
        name = timer_definition.name or "Unnamed Timer",
        time_left = timer_definition.duration,
        duration = timer_definition.duration,
        on_complete = timer_definition.on_complete or function() end,
        on_remove = timer_definition.on_remove or function() end,
        on_event = timer_definition.on_event,
        rounding_steps = timer_definition.rounding_steps or 10,
        ids = {bg = bg_id, bar = bar_id, label = text_id}
    }

    table.insert(
        timers[playername],
        timer
    )
    return timer
end

function remove_timer(playername, timer_index)
    timers[playername][timer_index].time_left = -1
    maintain_timers(timers[playername], 0, minetest.get_player_by_name(playername))
end

function remove_timer_by_reference(playername, timer)
    for index, other_timer in pairs(timers[playername]) do
        if timer == other_timer then
            return remove_timer(playername, index)
        end
    end
end

--Updates hud

function maintain_timers(timers, dtime, player)
    for i, timer in modlib.table.rpairs(timers) do
        local time_left = timer.time_left - dtime
        if time_left <= 0 then
            player:hud_remove(timer.ids.bg)
            player:hud_remove(timer.ids.bar)
            player:hud_remove(timer.ids.label)
            table.remove(timers, i)
            if timer.time_left > 0 then
                timer.on_complete(player:get_player_name(), timer)
            else
                timer.on_remove(player:get_player_name(), timer)
            end
        else
            timers[i].time_left = time_left
        end
    end
    for i, timer in ipairs(timers) do
        player:hud_change(
            timer.ids.label,
            "text",
            string.format(format, timer.name, modlib.number.round(timer.time_left, timer.rounding_steps))
        )
        player:hud_change(timer.ids.bar, "number", timer.time_left / timer.duration * 160)
        local y_offset = - (i-1) * 20
        player:hud_change(timer.ids.bg, "offset", {x = 0, y = y_offset})
        player:hud_change(timer.ids.bar, "offset", {x = 1, y = y_offset + 1})
        player:hud_change(timer.ids.label, "offset", {x = 2, y = y_offset})
    end
end

function update_timers(playername)
    maintain_timers(timers[playername], 0, minetest.get_player_by_name(playername))
end
