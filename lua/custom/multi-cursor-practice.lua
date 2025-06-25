local M = {}

function M.show_practice()
  local practice_text = [[
Multi-cursor Practice File
==========================

TRY THESE EXERCISES:

1. Basic Word Selection:
   Place cursor on 'test' and press <C-n> multiple times
   test function test_example() test

2. Column Selection:
   Use <M-C-Down> to create cursors on each line:
   name: "John"
   name: "Jane"  
   name: "Jack"

3. Select All Occurrences:
   Place cursor on 'TODO' and press \\A
   TODO: Fix this bug
   TODO: Add error handling
   TODO: Write tests

4. Variable Renaming:
   Select 'oldName' with <C-n> and change all:
   let oldName = getValue();
   console.log(oldName);
   return oldName + suffix;

5. Add Prefix/Suffix:
   Create cursors at line starts with visual + \\c
   item1
   item2
   item3

6. Function Arguments:
   Add cursors on commas to edit multiple args:
   function example(arg1, arg2, arg3, arg4) {

7. Quick Edits:
   Use ] and [ to navigate between cursors
   Use q to skip unwanted matches
   Use Q to remove a cursor

Press 'q' to close this buffer]]

  -- Create a new buffer with practice content
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(practice_text, '\n'))
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'javascript')
  
  -- Switch to the buffer
  vim.api.nvim_set_current_buf(buf)
  
  -- Add keymap to close
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':bdelete<CR>', { silent = true })
  
  -- Show help message
  vim.notify("Multi-cursor practice buffer created. Press 'q' to close.", vim.log.levels.INFO)
end

return M