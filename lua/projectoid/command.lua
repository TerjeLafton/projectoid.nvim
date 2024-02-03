local Project = require("projectoid.project")
local utils = require("projectoid.utils")

local M = {}

---Setup the Projectoid command
---@param pm ProjectManager The project manager to use
function M.setup_command(pm)
  vim.api.nvim_create_user_command("Projectoid", function(args)
    local subcommand = args.args
    if subcommand == "add" then
      local name, path, repl, run, test = utils.get_project_input()
      local project = Project.new(name, path, repl, run, test)
      pm:new_project(project)
    elseif subcommand == "edit" then
      vim.print("Edit project")
    elseif subcommand == "open" then
      pm:select_project()
    else
      vim.notify("Projectoid: " .. subcommand .. " is not a valid subcommand", vim.log.levels.ERROR)
    end
  end, {
    complete = function(start, _, _)
      local subcommands = { "add", "edit", "open" }
      local matches = {}

      for _, subcommand in ipairs(subcommands) do
        if subcommand:find(start) == 1 then
          table.insert(matches, subcommand)
        end
      end

      return matches
    end,
    desc = "Command for interacting with Projectoid",
    nargs = 1,
  })
end

return M
