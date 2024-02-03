---@class Migrator
---@field current_migration integer The current version of the database.
---@field db sqlite_db A valid sqlite connection.
local Migrator = {}
Migrator.__index = Migrator

---Constructor for Migrator
---@param db sqlite_db A valid sqlite connection.
---@return Migrator migrator An instance of the Migrator class.
function Migrator.new(db)
  local self = setmetatable({}, Migrator)
  self.db = db

  self:_setup_migrations_table()
  self.current_migration = self:_get_current_migration()
  self:_verify_migrations()
  self:_apply_migrations()

  return self
end

---Create the migrations table in the database if it does not exist
function Migrator:_setup_migrations_table()
  local result = self.db:eval([[
    CREATE TABLE IF NOT EXISTS migrations (
      version INTEGER PRIMARY KEY NOT NULL,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  ]])
  if not result then
    error("Projectoid: Could not create migrations table")
  end
end

---Get current migration from the database's migrations table
function Migrator:_get_current_migration()
  local result = self.db:eval(" SELECT version FROM migrations ORDER BY version DESC LIMIT 1")
  if type(result) == "boolean" then
    return 0
  else
    return result[1].version
  end
end

---Verify that all migration versions are applied
function Migrator:_verify_migrations()
  for expected_version = 1, self.current_migration do
    local version_exists =
      self.db:eval("SELECT version FROM migrations WHERE version = ?", { version = expected_version })
    if type(version_exists) == "boolean" then
      error(string.format("Projectoid: Missing migration version %d", expected_version))
    end
  end
end

---Apply all migrations
function Migrator:_apply_migrations()
  local migrations = {
    [1] = require("projectoid.database.migrations.1_create_project_table"),
    [2] = require("projectoid.database.migrations.2_add_repl_run_test_columns"),
  }

  for version, migration in ipairs(migrations) do
    if version > self.current_migration then
      for _, statement in ipairs(migration) do
        local migration_result = self.db:eval(statement)
        if not migration_result then
          error(string.format("Projectoid: Migration %d failed", version))
        end
      end

      local update_result = self.db:eval("INSERT INTO migrations (version) VALUES (?)", { version = version })
      if not update_result then
        error(string.format("Projectoid: Migration %d failed", version))
      end

      self.current_migration = version
    end
  end
end

return Migrator
