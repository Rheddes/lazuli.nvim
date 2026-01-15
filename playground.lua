local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local Job = require("plenary.job")

local get_pipelines = function()
    local job = Job:new({
        command = "az",
        args = { "pipelines", "list", "--output", "json" },
        cwd = "some-dir",
    })
    job:sync()
    local output = table.concat(job:result(), "\n")
    local json = vim.json.decode(output)
    return json
end

local pipeline_picker = function(opts, pipelines_tbl)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Pipelines",
            finder = finders.new_table({
                results = pipelines_tbl,
                entry_maker = function(entry)
                    local function make_display(entry_to_display)
                        local layout = {
                            separator = " ",
                            items = {
                                { width = 8 },
                                { width = 16 },
                                { remaining = true },
                            },
                        }
                        local columns = {
                            entry_to_display.value.id,
                            entry_to_display.value.path,
                            entry_to_display.value.name,
                        }
                        local displayer = entry_display.create(layout)
                        return displayer(columns)
                    end
                    return {
                        value = entry,
                        display = make_display,
                        ordinal = entry.name,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufr)
                    local selection = action_state.get_selected_entry()
                    -- print(vim.inspect(selection))
                    vim.api.nvim_put({ selection.value[2] }, "", false, true)
                end)
                return true
            end,
        })
        :find()
end

pipeline_picker({}, get_pipelines())
