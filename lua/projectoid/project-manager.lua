local Database = require("projectoid.database")
local ui = require("projectoid.ui")
local utils = require("projectoid.utils")

---@class ProjectManager
---@field active_project Project|nil The active project.
---@field db Database The database instance.
local ProjectManager = {}
ProjectManager.__index = ProjectManager

---Constructor for the ProjectManager class.
---@return ProjectManager instance ProjectManager instance.
function ProjectManager.new()
  local self = setmetatable({}, ProjectManager)
  self.active_project = nil
  self.db = Database.new()
  return self
end

---Creates a new project with the given name and path.
---@param project Project The project to add.
function ProjectManager:new_project(project)
  if self.db:insert_project(project) then
    vim.notify("Project " .. project.name .. " added", vim.log.levels.INFO)
  end
end

-- function ProjectManager:edit_project(project) end

---Opens a project picker to select a project to open.
function ProjectManager:select_project()
  ui.open_menu(self.db:get_projects(), function(project)
    self:open_project(project)
  end)
end

---Opens the project with the given id.
---@param project Project The id of the project to open.
function ProjectManager:open_project(project)
  vim.print(project)
  if vim.fn.confirm("Set active project to " .. project.name .. "?", "&Yes\n&Cancel", 2, "Question") ~= 1 then
    return
  end

  utils.close_buffers()
  vim.api.nvim_set_current_dir(project.path)
  self.active_project = project
  utils.open_readme()
  vim.notify("Project " .. project.name .. " opened", vim.log.levels.INFO)
end

return ProjectManager
