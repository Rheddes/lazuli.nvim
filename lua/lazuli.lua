local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local Azure = require("azure")

local M = {}
-- TODO: Maybe Private?
M.make_display = function(entry)
    local layout = {
        separator = " ",
        items = {
            { width = 8 },
            { width = 16 },
            { remaining = true },
        },
    }
    local columns = {
        entry.value.id,
        entry.value.path,
        entry.value.name,
    }
    local displayer = entry_display.create(layout)
    return displayer(columns)
end

-- TODO: Maybe Private?
M.gen_from_pipeline = function(pipeline)
    return {
        value = pipeline,
        display = M.make_display,
        ordinal = pipeline.name,
    }
end
M.pipeline_picker = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Pipelines",
            finder = finders.new_table({
                results = Azure.get_pipelines(),
                entry_maker = M.gen_from_pipeline,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufr)
                    local selection = action_state.get_selected_entry()
                    Azure.start_pipeline(selection.value)
                end)
                return true
            end,
        })
        :find()
end
return M

