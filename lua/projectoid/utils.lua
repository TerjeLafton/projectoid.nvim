local home = require("plenary.path").path.home

local M = {}

function M.close_buffers()
  local buffers = vim.api.nvim_list_bufs()

  for _, buffer in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buffer) then
      vim.api.nvim_buf_delete(buffer, {})
    end
  end
end

function M.open_readme()
  local readme_path = vim.fn.getcwd() .. "/README.md"

  if vim.fn.filereadable(readme_path) == 1 then
    vim.cmd("edit " .. readme_path)
  end
end

function M.get_project_input()
  local name = vim.fn.input("Enter name: ")
  local path = vim.fn.input("Enter path: ", home, "dir")
  local run = vim.fn.input("Enter run command: ")
  local test = vim.fn.input("Enter test command: ")
  local repl = vim.fn.input("Enter REPL command: ")

  return name, path, repl, run, test
end

return M
