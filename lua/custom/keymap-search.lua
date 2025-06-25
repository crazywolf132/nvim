local M = {}

local function get_keymap_category(desc, keys)
  if not desc then return "Other" end
  
  local desc_lower = desc:lower()
  
  if desc_lower:match("multi.?cursor") or desc_lower:match("visual.?multi") then
    return "Multi-cursor"
  elseif desc_lower:match("lsp") or desc_lower:match("diagnostic") or desc_lower:match("code action") or desc_lower:match("definition") or desc_lower:match("reference") then
    return "LSP/Code"
  elseif desc_lower:match("git") or desc_lower:match("hunk") or desc_lower:match("blame") or desc_lower:match("diff") then
    return "Git"
  elseif desc_lower:match("test") or desc_lower:match("debug") then
    return "Testing/Debug"
  elseif desc_lower:match("find") or desc_lower:match("search") or desc_lower:match("telescope") or desc_lower:match("grep") then
    return "Search/Find"
  elseif desc_lower:match("file") or desc_lower:match("explorer") or desc_lower:match("tree") or desc_lower:match("oil") then
    return "File Management"
  elseif desc_lower:match("buffer") or desc_lower:match("window") or desc_lower:match("tab") or desc_lower:match("split") then
    return "Navigation"
  elseif desc_lower:match("terminal") or desc_lower:match("toggleterm") then
    return "Terminal"
  elseif desc_lower:match("format") or desc_lower:match("lint") or desc_lower:match("indent") then
    return "Formatting"
  elseif desc_lower:match("comment") then
    return "Comments"
  elseif desc_lower:match("fold") then
    return "Folding"
  elseif desc_lower:match("mark") or desc_lower:match("bookmark") or desc_lower:match("harpoon") then
    return "Marks/Bookmarks"
  elseif desc_lower:match("surround") or desc_lower:match("pair") or desc_lower:match("bracket") then
    return "Text Objects"
  elseif desc_lower:match("yank") or desc_lower:match("paste") or desc_lower:match("copy") then
    return "Clipboard"
  elseif keys and keys:match("^<[Cc]%-") then
    return "Control Keys"
  elseif keys and keys:match("^<[Dd]%-") then
    return "Command Keys (macOS)"
  elseif keys and keys:match("^<leader>") then
    return "Leader Keys"
  else
    return "Other"
  end
end

local function format_keymap_entry(keymap, category)
  local mode_display = {
    n = "NORMAL",
    i = "INSERT", 
    v = "VISUAL",
    x = "VISUAL",
    s = "SELECT",
    o = "OPERATOR",
    t = "TERMINAL",
    c = "COMMAND",
  }
  
  local mode = mode_display[keymap.mode] or keymap.mode:upper()
  local desc = keymap.desc or keymap.rhs or "No description"
  local keys = keymap.lhs
  
  return string.format("[%s] %-20s → %-50s [%s]", mode, keys, desc, category)
end

function M.search_keymaps()
  local fzflua = require("fzf-lua")
  
  local keymaps = {}
  local categorized = {}
  
  for _, mode in ipairs({"n", "i", "v", "x", "s", "o", "t", "c"}) do
    local mode_keymaps = vim.api.nvim_get_keymap(mode)
    for _, keymap in ipairs(mode_keymaps) do
      keymap.mode = mode
      local category = get_keymap_category(keymap.desc, keymap.lhs)
      
      if not categorized[category] then
        categorized[category] = {}
      end
      table.insert(categorized[category], keymap)
    end
    
    local buf_keymaps = vim.api.nvim_buf_get_keymap(0, mode)
    for _, keymap in ipairs(buf_keymaps) do
      keymap.mode = mode
      keymap.buffer = true
      local category = get_keymap_category(keymap.desc, keymap.lhs)
      
      if not categorized[category] then
        categorized[category] = {}
      end
      table.insert(categorized[category], keymap)
    end
  end
  
  local entries = {}
  local category_order = {
    "Multi-cursor",
    "LSP/Code",
    "Git",
    "Search/Find",
    "File Management",
    "Navigation",
    "Terminal",
    "Testing/Debug",
    "Formatting",
    "Comments",
    "Folding",
    "Marks/Bookmarks",
    "Text Objects",
    "Clipboard",
    "Control Keys",
    "Command Keys (macOS)",
    "Leader Keys",
    "Other"
  }
  
  for _, category in ipairs(category_order) do
    if categorized[category] then
      table.insert(entries, string.format("──────── %s ────────", category))
      
      table.sort(categorized[category], function(a, b)
        return (a.lhs or "") < (b.lhs or "")
      end)
      
      for _, keymap in ipairs(categorized[category]) do
        table.insert(entries, format_keymap_entry(keymap, category))
      end
      table.insert(entries, "")
    end
  end
  
  fzflua.fzf_exec(entries, {
    prompt = "Keymaps> ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          local line = selected[1]
          local keys = line:match("%[%w+%] (.-)%s+→")
          if keys then
            keys = keys:gsub("^%s+", ""):gsub("%s+$", "")
            vim.notify("Keymap: " .. keys, vim.log.levels.INFO)
          end
        end
      end,
    },
    winopts = {
      height = 0.85,
      width = 0.85,
      preview = {
        hidden = "hidden",
      },
    },
    fzf_opts = {
      ["--info"] = "inline",
      ["--no-separator"] = "",
    },
  })
end

function M.search_keymaps_by_feature()
  local feature_keywords = {
    ["Multi-cursor"] = {"<C-n>", "<C-p>", "<C-x>", "visual-multi", "cursor"},
    ["Git operations"] = {"git", "hunk", "blame", "diff", "commit", "push", "pull"},
    ["Code navigation"] = {"definition", "reference", "implementation", "declaration"},
    ["File operations"] = {"save", "quit", "open", "close", "new file"},
    ["Search"] = {"find", "grep", "search", "telescope"},
    ["Testing"] = {"test", "debug", "breakpoint"},
    ["Terminal"] = {"terminal", "toggleterm", "lazygit"},
    ["Comments"] = {"comment", "uncomment"},
    ["Formatting"] = {"format", "indent", "align"},
    ["Folding"] = {"fold", "unfold", "toggle fold"},
    ["Window management"] = {"split", "vsplit", "window", "tab"},
  }
  
  local choices = {}
  for feature, _ in pairs(feature_keywords) do
    table.insert(choices, feature)
  end
  table.sort(choices)
  
  require("fzf-lua").fzf_exec(choices, {
    prompt = "Search feature> ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          local feature = selected[1]
          local keywords = feature_keywords[feature]
          
          vim.schedule(function()
            local pattern = table.concat(keywords, "|")
            require("fzf-lua").keymaps({
              search = pattern,
              winopts = {
                title = "Keymaps: " .. feature,
                title_pos = "center",
              },
            })
          end)
        end
      end,
    },
    winopts = {
      height = 0.4,
      width = 0.4,
    },
  })
end

return M