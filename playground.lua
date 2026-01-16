local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local Job = require("plenary.job")

local cwd = "some_dir"

local Git = {}
Git.get_current_branch = function()
    local branch_job = Job:new({
        command = "git",
        args = { "rev-parse", "--abbrev-ref", "HEAD" },
        cwd = cwd,
    })
    branch_job:sync()
    return  branch_job:result()[1]
end

local Azure = {}
Azure.get_pipelines = function()
    local job = Job:new({
        command = "az",
        args = { "pipelines", "list", "--output", "json" },
        cwd = cwd,
    })
    job:sync()
    local output = table.concat(job:result(), "\n")
    local json = vim.json.decode(output)
    return json
end
Azure.start_pipeline = function(pipeline)
    local job = Job:new({
        command = "az",
        args = { "pipelines", "run", "--output", "json", "--id", pipeline.id, "--branch", Git.get_current_branch() },
        cwd = cwd,
    })
    job:sync()
    local output = table.concat(job:result(), "\n")
    local json = vim.json.decode(output)
    print(vim.inspect(json))
end

local M = {}
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

M.gen_from_pipeline = function(pipeline)
    return {
        value = pipeline,
        display = M.make_display,
        ordinal = pipeline.name,
    }
end
M.pipeline_picker = function(opts, pipelines_tbl)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Pipelines",
            finder = finders.new_table({
                results = pipelines_tbl,
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

M.pipeline_picker({}, Azure.get_pipelines())
