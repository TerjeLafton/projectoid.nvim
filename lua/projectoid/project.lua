---@class Project
---@id integer|nil The id of the project.
---@field name string The name of the project.
---@field path string The path to the root of the project.
---@field repl string Command to start a REPL for the project.
---@field run string Command to start run the project.
---@field test string Command to start run tests for the project.
local Project = {}
Project.__index = Project

---Constructor for the Project class.
---@param name string The name of the project.
---@param path string The path to the root of the project.
---@param repl string Command to start a REPL for the project.
---@param run string Command to run the project.
---@param test string Command to run tests for the project.
function Project.new(name, path, repl, run, test)
  local self = setmetatable({}, Project)

  if name == "" then
    vim.notify("Projectoid: Name cannot be empty", vim.log.levels.ERROR, {})
  end
  if path == "" then
    vim.notify("Projectoid: Path cannot be empty", vim.log.levels.ERROR, {})
  end
  if vim.fn.isdirectory(path) == 0 then
    vim.notify("Projectoid: Path " .. path .. " does not exist or is not a directory", vim.log.levels.ERROR, {})
  end

  self.name = name
  self.path = path
  self.repl = repl
  self.run = run
  self.test = test

  return self
end

return Project
