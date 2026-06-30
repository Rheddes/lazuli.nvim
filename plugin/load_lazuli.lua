vim.api.nvim_create_user_command("AzPipeline", function()
    -- Easy Reloading
    package.loaded["lazuli"] = nil

    require("lazuli").pipeline_picker()
end, {})
