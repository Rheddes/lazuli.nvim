local Job = require("plenary.job")

local Git = {}
Git.get_current_branch = function()
    local branch_job = Job:new({
        command = "git",
        args = { "rev-parse", "--abbrev-ref", "HEAD" },
        cwd = vim.fn.getcwd(),
    })
    branch_job:sync()
    return  branch_job:result()[1]
end
return Git
