return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'md' },
    event = { 'BufReadPre *.md', 'BufNewFile *.md' },
    config = function()
        require('render-markdown').setup({
            -- Enable or disable the plugin
            enabled = true,
            -- Maximum file size in MB to render
            max_file_size = 10.0,
            -- Capture groups for markdown links
            log_capture = false,
            -- Filetypes to enable rendering
            file_types = { 'markdown' },
            -- Vim modes to enable rendering
            render_modes = { 'n', 'v', 'i', 'c' },
            -- Characters to use for different elements
            heading = {
                -- Turn on / off heading icon & background rendering
                enabled = true,
                -- Turn on / off any sign column related rendering
                sign = true,
                -- Replaces '#+' of 'atx_h._marker'
                -- The number of '#' in the heading determines the 'level'
                -- The 'level' is used to index into the array using a cycle
                icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                -- Added to the sign column if enabled
                -- The 'level' is used to index into the array using a cycle
                signs = { '󰫎 ' },
                -- The 'level' is used to index into the array using a clamp
                -- Highlight for the heading icon and extends through the entire line
                backgrounds = {
                    'RenderMarkdownH1Bg',
                    'RenderMarkdownH2Bg',
                    'RenderMarkdownH3Bg',
                    'RenderMarkdownH4Bg',
                    'RenderMarkdownH5Bg',
                    'RenderMarkdownH6Bg',
                },
                -- The 'level' is used to index into the array using a clamp
                -- Highlight for the heading and sign icons
                foregrounds = {
                    'RenderMarkdownH1',
                    'RenderMarkdownH2',
                    'RenderMarkdownH3',
                    'RenderMarkdownH4',
                    'RenderMarkdownH5',
                    'RenderMarkdownH6',
                },
            },
            -- Code block rendering
            code = {
                -- Turn on / off code block & inline code rendering
                enabled = true,
                -- Turn on / off any sign column related rendering
                sign = true,
                -- Determines how code blocks & inline code are rendered
                style = 'full',
                -- Highlight for code blocks & inline code
                highlight = 'RenderMarkdownCode',
                highlight_inline = 'RenderMarkdownCodeInline',
            },
            -- Bullet point rendering
            bullet = {
                -- Turn on / off bullet rendering
                enabled = true,
                -- Replaces '-'|'+'|'*' of 'list_item'
                -- How deeply nested the list is determines the 'level'
                -- The 'level' is used to index into the array using a cycle
                -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
                icons = { '●', '○', '◆', '◇' },
                -- Highlight for the bullet icon
                highlight = 'RenderMarkdownBullet',
            },
            -- Checkbox rendering
            checkbox = {
                -- Turn on / off checkbox rendering
                enabled = true,
                unchecked = {
                    -- Replaces '[ ]' of 'task_list_marker_unchecked'
                    icon = '󰄱 ',
                    -- Highlight for the icon
                    highlight = 'RenderMarkdownUnchecked',
                },
                checked = {
                    -- Replaces '[x]' of 'task_list_marker_checked'
                    icon = '󰱒 ',
                    -- Highlight for the icon
                    highlight = 'RenderMarkdownChecked',
                },
                -- Define custom checkbox states
                custom = {
                    todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
                },
            },
            -- Quote block rendering
            quote = {
                -- Turn on / off quote rendering
                enabled = true,
                -- Replaces '>' of 'block_quote'
                icon = '▎',
                -- Highlight for the quote icon
                highlight = 'RenderMarkdownQuote',
            },
            -- Table rendering
            table = {
                -- Turn on / off table rendering
                enabled = true,
                -- Determines how tables are rendered
                style = 'full',
                -- Characters used to replace table border
                -- Correspond to: top_left, top_mid, top_right, mid_left, mid_mid, mid_right, bottom_left, bottom_mid, bottom_right
                cell_border = { '┌', '┬', '┐', '├', '┼', '┤', '└', '┴', '┘' },
                -- Highlight for table heading, delimiter, and the rest of the table
                head = 'RenderMarkdownTableHead',
                row = 'RenderMarkdownTableRow',
                filler = 'RenderMarkdownTableFill',
            },
            -- Callout rendering
            callout = {
                note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
                tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
                important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
                warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
                caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
                -- Add custom callouts
                abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
                todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
                success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
                question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
                failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
                danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
                bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
                example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
                quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
            },
            -- Link rendering
            link = {
                -- Turn on / off link rendering
                enabled = true,
                -- Inlined with 'image' elements
                image = '󰥶 ',
                -- Inlined with 'inline_link' elements
                hyperlink = '󰌹 ',
                -- Applies to the inlined icon
                highlight = 'RenderMarkdownLink',
            },
            -- Thematic break rendering
            thematic_break = {
                -- Turn on / off thematic break rendering
                enabled = true,
                -- Replaces '---'|'***'|'___'
                icon = '─',
                -- Highlight for the icon
                highlight = 'RenderMarkdownDash',
            },
            -- LaTeX rendering
            latex = {
                -- Turn on / off LaTeX rendering
                enabled = true,
                -- Highlight for LaTeX
                highlight = 'RenderMarkdownMath',
            },
            -- Configure which file types to render
            acknowledge_conflicts = true,
            -- Keybinding to toggle rendering
            toggle = {
                key = '<leader>mt',
                desc = 'Toggle markdown rendering',
            },
        })
    end,
}