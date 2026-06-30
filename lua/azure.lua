local Job = require("plenary.job")
local Git = require("git")

local Azure = {}
Azure.get_pipelines = function()
    local job = Job:new({
        command = "az",
        args = { "pipelines", "list", "--output", "json" },
        cwd = vim.fn.getcwd(),
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
        cwd = vim.fn.getcwd(),
    })
    job:sync()
    local output = table.concat(job:result(), "\n")
    -- local json = vim.json.decode(output)
    -- print(vim.inspect(json))
    print("Started pipeline: " .. pipeline.id)
end
return Azure
