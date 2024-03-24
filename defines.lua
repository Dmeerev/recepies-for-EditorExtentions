local defines = {}
local dummy_underground_belt_item = {type="item", name="underground-belt", amount=1}
local ftable = require("__flib__/table")

defines.item_processing_prefix = "item"
defines.recipes = {
    --logistic
    ["ee-linked-belt"]={
        type = "defined",
        recipe = {
            {type="item", name="cargo-wagon", amount=1},
            --[[
                Let's imagine that the electric motor has a power of 5 kW
                (based on a 200 kW exoskeleton with 30 motors in the recipe)
                and this means that we need 120 to achieve the 600kW(vanila locomotive) figure.
            ]]
            {type="item", name="electric-engine-unit", amount=120},
            {type="item", name="processing-unit", amount=60},
            dummy_underground_belt_item,                                    --update to real one in init_items_table
            --{type="item", name="fusion-reactor-equipment", amount=1},     --should be added to init_balancing_items_table_post_recepies_process
        }},
    ["ee-linked-chest"]={
        type = "defined",
        --[[
            According to my calculations, using 1 super inserters you can achieve a speed of 360 items per second using these chests!
            therefore, 360/45 = 8, also multiply by 4 sides and get 32 conveyors!
            But i give off 75% price for motivating build that massive unloaders!
        ]]
        recipe = {
            {type="item", name="ee-linked-belt", amount=8},
            {type="item", name="steel-chest", amount=1},
        }},
    ["ee-super-inserter"]={},
    ["ee-super-locomotive"]={},
    ["ee-super-pump"]={},

    --energy
    ["ee-super-electric-pole"]={},
    ["ee-super-fuel"]={
        type = defines.item_processing_prefix.."_generated",
        name_filter = "fuel",
        search_rows = {fuel_value = 1, fuel_acceleration_multiplier = 1, fuel_top_speed_multiplier = 1},
    },
    ["ee-super-substation"]={},

    --equipment
    ["ee-infinity-fusion-reactor-equipment"]={},
    ["ee-super-energy-shield-equipment"]={},
    ["ee-super-battery-equipment"]={},
    ["ee-super-exoskeleton-equipment"]={},
    ["ee-super-night-vision-equipment"]={
        type = "defined",
        recipe = {
            {type="item", name="night-vision-equipment", amount=1},
            {type="item", name="processing-unit", amount=50},
            {type="item", name="effectivity-module", amount=1},
        }
    },
    ["ee-super-personal-roboport-equipment"]={},

    --robots
    ["ee-super-construction-robot"]={},
    ["ee-super-logistic-robot"]={},
    ["ee-super-roboport"]={},

    --modules/effects
    ["ee-super-beacon"]={},
    ["ee-super-speed-module"]={},
    ["ee-super-effectivity-module"]={},
    ["ee-super-productivity-module"]={},
    ["ee-super-clean-module"]={},
    ["ee-super-slow-module"]={},
    ["ee-super-ineffectivity-module"]={},
    ["ee-super-dirty-module"]={},

    --other
    ["ee-super-lab"]={},
    ["ee-super-radar"]={},
}

for _, value in pairs(defines.recipes) do
    if not value.type then
        value.type = "generated"
        value.recipe = {}
    end
end

local function empty_function(data_raw_category, recipe_object--[[, recipes_table, types_table]])
    if recipe_object then
        log('empty_function call detected! this shouldnt have happened! prototype: '..recipe_object.name)
    end
end

defines.types = {
    --defined
    ["linked-belt"] = {
        keyword = "defined"
    },

    ["linked-container"] = {
        keyword = "defined"
    },

    ["night-vision-equipment"] = {
        keyword = "defined",
        restrict_power_fix = true
    },

    --base_property
    ["construction-robot"] = {
        keyword = "base_property",
        search_rows = {"max_payload_size", "speed"}
    },

    ["logistic-robot"] = {
        keyword = "base_property",
        search_rows = {"max_payload_size", "speed"}
    },

    ["inserter"] = {
        keyword = "base_property",
        search_rows = {["rotation_speed"] = 21600, "stack"}
    },

    ["lab"] = {
        keyword = "base_property",
        search_rows = {"researching_speed"}
    },

    ["pump"] = {
        keyword = "base_property",
        search_rows = {"pumping_speed"}
    },

    ["energy-shield-equipment"] = {
        keyword = "base_property",
        search_rows = {"max_shield_value"},
        restrict_power_fix = true
    },

    ["movement-bonus-equipment"] = {
        keyword = "base_property",
        search_rows = {"movement_bonus"},
        --restrict_power_fix = true     --disabled because power consumption too low
    },

    --energy related stuff but compatible with base_property(thanks flib)
    ["locomotive"] = {
        keyword = "base_property",
        search_rows = {"max_speed", "max_power"}
    },

    ["generator-equipment"] = {
        keyword = "base_property",
        search_rows = {"power"},
        restrict_power_fix = true
    },

    ["solar-panel-equipment"] = {
        keyword = "base_property",
        search_rows = {"power"}
    },

    --with area
    ["radar"] = {
        keyword = "base_property",
        --[[
            I ignore max_distance_of_sector_revealed("scan" radius)
            due to the overlapping of these values ​​with each other when the game actually
            scanning radius is calculated by active_radius * scanning_radius
        ]]
        search_rows = {["max_distance_of_nearby_sector_revealed"] = "^2"}
    },

    ["roboport"] = {
        keyword = "base_property",
        search_rows = {["logistics_radius"] = "^2", ["construction_radius"] = "^2"}
    },

    ["roboport-equipment"] = {
        keyword = "base_property",
        search_rows = {["construction_radius"] = "^2"},
        restrict_power_fix = true
    },

    ["beacon"] = {
        keyword = "base_property",
        search_rows = {["supply_area_distance"] = "^2"}
    },

    ["electric-pole"] = {
        keyword = "base_property",
        search_rows = {"maximum_wire_distance", ["supply_area_distance"] = "^2"}
    },

    --items are too complex for processing, i just moved search_rows to recipes table
    ['item'] = {
        keyword = "items",
    },

    --other
    ["module"] = {
        keyword = "modules",
        restrict_power_fix = true   --just in case
    },

    ["battery-equipment"] = {
        keyword = "base_property",
        search_rows = {"energy_source/buffer_capacity"},
        restrict_power_fix = true
    },
}

--filling in all missing fields by default
for _, type in pairs(defines.types) do
    type.func = empty_function
    type.top_items = {}

    if not type['search_rows'] then
        type.search_rows = {}
    end

    if not type['keyword'] then
        type.keyword = ""
    end
end

--convert subtables in search_rows like {"power"} to {["power"]=1}
for _, types in pairs(defines.types) do
    for row_name, row in pairs(types.search_rows) do
        if type(row_name) == "number" then
            types.search_rows[row] = 1
            types.search_rows[row_name] = nil
        end
    end
end

function defines.set_function_by_keyword(keyword, func)
    for _, value in pairs(defines.types) do
        if value.keyword == keyword then
            value["func"] = func
        end
    end
end

--[[
    table for additional balancing
    for example adding generators to "no power requirements" items
    or effects to modules that do not have corresponding modules in vanilla
]]
defines.balancing_items_table = {
    effect = {
        --[[
            values ​​are written as top_items.data, For example {"item name", effect fon 1 item},
            because this is only needed to compensate for the effects of the modules
        ]]
        positive = {
            pollution = {"flamethrower-ammo", 5/100},         --1 item can create up to 5 units of pollution
            consumption = {"copper-cable", 1/20},           --according to my calculations, 1 cable is capable of transmitting ~10 kW(average between furnace and assembler consumption per wire), which means that to add 100% to consumption for electric-furnace you need 18 cables
            speed = {"electric-engine-unit", 1/100},        --essentially a random item, needed for the user to be able to install a custom item
            productivity = {"productivity-module", 4/100}   --same as with speed effect
        },
        negative = {
            pollution = {"wood", -1/100},                  --wood absorbs pollution
            consumption = {"battery", -1/100},              --same as with positive speed effect
            speed = {"heavy-oil-barrel", -1/250},          --let's imagine that this module pours fuel oil onto the gears, causing a slowdown :)
            productivity = {"raw-fish", -1/100}            --I have no idea what to put here, but a module with this effect is not needed at all
        }
    },
    energy = {
--[[        heat = {

        },]]
        electric = {

        },
--[[        battery = {

        }]]
    }
}

--definitions for settings
defines.prefixes = {
    mod = "rfEE",
    balancing = "_balancing",
    name = "a-item-name",
    value = "effect-value",
    effect_values = {
        --set value for {minimum, maximum}
        positive = {0, 100},
        negative = {-100, 0},
    }
}
for prefix, value in pairs(defines.prefixes) do
    if type(value) == 'string' then
        defines.prefixes[prefix] = value .. "_"
    end
end

--filling out a table for energy where the “best items” are not known in advance
function defines.init_items_table(data_raw, settings_startup) --must be called from code with access to data.raw
    --modules
    local effect_table
    for setting_name, value in pairs(settings_startup) do
        if setting_name:sub(1, #defines.prefixes.mod) == defines.prefixes.mod then
            local _, _, effect_sign, nameorvalue, effect_name = setting_name:find("rfEE_(%w+)"..defines.prefixes.balancing.."([%w-]+_)(%w+)")
            if effect_sign and nameorvalue and effect_name then
                effect_table = defines.balancing_items_table.effect[effect_sign][effect_name]
                if nameorvalue == defines.prefixes.name then
                    effect_table[1] = value.value
                elseif nameorvalue == defines.prefixes.value then
                    effect_table[2] = value.value
                end
            end
        end
    end

    --correct underground conveyor for linked conveyor(part of the code from EE)
    local fastest_speed, fastest_speed_protoname, recipe_rows = 0, "", defines.recipes["ee-linked-belt"].recipe
    for _, prototype in pairs(data.raw["underground-belt"]) do
      if prototype.speed > fastest_speed then
        fastest_speed = prototype.speed
        fastest_speed_protoname = prototype.name
      end
    end
    local ind = ftable.find(recipe_rows, dummy_underground_belt_item)
    if ind then
        recipe_rows[ind].name = fastest_speed_protoname
    end
end

function defines.init_balancing_items_table_post_recepies_process(data_raw, settings_startup)
    local utils = require("utils")
    local elect_table = defines.balancing_items_table.energy.electric
    local next_index = 0

    local function my_comp(a, b)
        return a[2] < b[2]
    end

    --energy
    local compensation_cat = settings_startup["rfEE_type_of_compensation_category"].value
    local type_tabl_defines = defines.types[compensation_cat]
    if type_tabl_defines then
        for raw_name, raw_table in pairs(data_raw[compensation_cat]) do
            table.insert(elect_table, {raw_name, utils.find_diff_value(type_tabl_defines.search_rows, raw_table)})
        end
        while not utils.is_sorted(elect_table, my_comp) do
            next_index = ftable.partial_sort(elect_table, next_index, 1, my_comp)
        end
    else
        log('warning! the specified category does not exist(data.raw: '..tostring(data_raw[compensation_cat])..', rwEE types table:'..tostring(type_tabl_defines)..' )!(should not be nil)')
    end

    if #defines.balancing_items_table.energy.electric > 0 then
        --adding reactor to linked conveyor
        table.insert(defines.recipes["ee-linked-belt"].recipe, {type="item", name=defines.balancing_items_table.energy.electric[1][1], amount=1})
    end
end

return defines