local Migrator = require("projectoid.database.migrator")
local sqlite = require("sqlite.db")

---@class Database
---@field db sqlite_db A connection to the database.
---@field migrator Migrator The class responsible of migrations.
local Database = {}
Database.__index = Database

---Constructor for the Database class.
---@return Database database Database instance.
function Database.new()
  local self = setmetatable({}, Database)
  local path = vim.fn.stdpath("data") .. "/databases/projectoid.db"
  self.db = sqlite:open(path, nil)
  self.migrator = Migrator.new(self.db)

  return self
end

---Insert a new project into the database.
---@param project Project The project to be inserted.
function Database:insert_project(project)
  local exists = self.db:eval("SELECT name FROM projects where name = ?", { name = project.name })
  if type(exists) == "table" then
    vim.notify("Project already exists", vim.log.levels.ERROR)
    return
  end

  local results = self.db:eval("INSERT INTO projects (name, path, repl, run, test) VALUES (?, ?, ?, ?, ?)", {
    project.name,
    project.path,
    project.repl,
    project.run,
    project.test,
  })
  if not results then
    vim.notify("Failed to add new project", vim.log.levels.ERROR)
  end
end

---Get all projects from the database.
---@return Project[] Projects List of all projects.
function Database:get_projects()
  local result = self.db:eval("SELECT * FROM projects")
  if type(result) == "boolean" then
    return {}
  end

  return result
end

---Get a project by its ID.
---@param id integer The ID of the project.
---@return Project project The project matching the given ID.
function Database:get_project(id)
  local result = self.db:eval("SELECT * FROM projects WHERE id = ? LIMIT 1", { id = id })
  if type(result) == "boolean" then
    vim.notify("Project not found", vim.log.levels.ERROR)
    return {}
  end

  return result[1]
end

---Update an existing project in the database.
---@param id integer The ID of the project.
---@param changes table A table of changes with column names as keys and new values as values.
function Database:update_project(id, changes)
  if changes.name then
    local exists = self.db:eval("SELECT name FROM projects where name = ?", { name = changes.name })
    if type(exists) == "table" then
      vim.notify("Project already exists", vim.log.levels.ERROR)
      return
    end
  end

  local params = {}
  local set_clauses = {}
  local sql = "UPDATE projects SET "

  for column, value in pairs(changes) do
    table.insert(set_clauses, column .. " = ?")
    table.insert(params, value)
  end

  sql = sql .. table.concat(set_clauses, ", ") .. " WHERE id = ?"
  table.insert(params, id)

  vim.print(sql, params)
  -- local results = self.db:eval(sql, params)
  -- if not results then
  --   vim.notify("Failed to update project", vim.log.levels.ERROR)
  -- else
  --   vim.notify("Project updated successfully", vim.log.levels.INFO)
  -- end
end

---Delete a project by its ID.
---@param id integer The ID of the project.
function Database:delete_projct(id)
  local exists = self.db:eval("SELECT * FROM projects WHERE id = ? LIMIT 1", { id = id })
  if type(exists) == "boolean" then
    vim.notify("Project not found", vim.log.levels.ERROR)
    return
  end

  local result = self.db:eval("DELETE FROM projects WHERE id = ?", { id = id })
  if not result then
    vim.notify("Failed to delete project", vim.log.levels.ERROR)
  end
end

return Database
