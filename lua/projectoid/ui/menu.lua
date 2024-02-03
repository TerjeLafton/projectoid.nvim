local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")

---Opens a telescope picker for the given options.
---@param projects Project[] A table of options to display in the picker.
---@param callback fun(project: Project) The function to call when a selection is made.
return function(projects, callback)
  pickers
    .new(themes.get_dropdown(conf.opts), {
      prompt_title = "colors",
      finder = finders.new_table({
        results = projects,
        entry_maker = function(entry)
          return { value = entry, display = entry.name, ordinal = entry.name }
        end,
      }),
      sorter = conf.generic_sorter(conf.opts),
      attach_mappings = function(bufnr, _)
        actions.select_default:replace(function()
          actions.close(bufnr)
          local selection = action_state.get_selected_entry()
          callback(selection.value)
        end)
        return true
      end,
    })
    :find()
end
