local command = require("projectoid.command")

local M = {}

function M.setup()
  local pm = require("projectoid.project-manager").new()
  command.setup_command(pm)
end

return M
