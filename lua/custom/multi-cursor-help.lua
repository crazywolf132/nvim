local M = {}

function M.show_help()
  local help_text = [[
Multi-cursor Operations (vim-visual-multi)
==========================================

CORE SELECTION:
  <C-n>         Select word & find next occurrence
  <M-C-Down>    Add cursor below (Alt+Ctrl+Down)
  <M-C-Up>      Add cursor above (Alt+Ctrl+Up)
  \\A           Select ALL occurrences of word
  
VISUAL MODE:
  \\a           Add cursor at position
  \\f           Find pattern in selection
  \\c           Create cursors from visual selection
  
NAVIGATION:
  ]             Go to next cursor
  [             Go to previous cursor
  <Tab>         Switch cursor/extend mode
  q             Skip current & find next
  Q             Remove current cursor
  
MOUSE SUPPORT:
  <C-LeftMouse>    Add cursor with click
  <C-RightMouse>   Select word with click
  
SELECTION MODIFICATION:
  +             Expand selection
  -             Shrink selection
  }             Motion to next
  {             Motion to previous
  
EDITING:
  c             Change
  s             Substitute
  i/a           Insert before/after
  I/A           Insert at line start/end
  o/O           Open line below/above
  
ALIGNMENT:
  \\a           Align cursors
  \\<           Align by character
  \\>           Align by regex
  
COMMANDS:
  u             Undo
  <C-r>         Redo
  <Esc>         Exit multi-cursor mode
  \\<Space>     Toggle single region mode

TIP: Use <leader>fK to search all keybindings!

Press any key to close...]]

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(help_text, '\n'))
  
  local width = 50
  local height = 30
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Multi-cursor Help ',
    title_pos = 'center',
  })
  
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':q<CR>', { silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { silent = true })
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
end

return M