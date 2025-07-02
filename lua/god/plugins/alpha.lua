return {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
        local alpha = require('alpha')
        local dashboard = require('alpha.themes.dashboard')

        -- ASCII art header
        dashboard.section.header.val = {
            [[         .m.                                   ,_     ]],
            [[         ' ;M;                                ,;m `   ]],
            [[           ;M;.           ,      ,           ;SMM;    ]],
            [[          ;;Mm;         ,;  ____  ;,         ;SMM;    ]],
            [[         ;;;MM;        ; (.MMMMMM.) ;       ,SSMM;;   ]],
            [[       ,;;;mMp'        l  ';mmmm;/  j       SSSMM;;   ]],
            [[     .;;;;;MM;         .\,.mmSSSm,,/,      ,SSSMM;;;  ]],
            [[    ;;;;;;mMM;        .;MMmSSSSSSSmMm;     ;MSSMM;;;; ]],
            [[   ;;;;;;mMSM;     ,_ ;MMmS;;;;;;mmmM;  -,;MMMMMMm;;;;]],
            [[  ;;;;;;;MMSMM;     \*;M;( ( '') );m;*/ ;MMMMMM;;;;;, ]],
            [[ .;;;;;;mMMSMM;      \(@;! _     _ !;@)/ ;MMMMMMMM;;;;;,]],
            [[ ;;;;;;;MMSSSM;       ;,;.*o*> <*o*.;m; ;MMMMMMMMM;;;;;;,]],
            [[.;;;;;;;MMSSSMM;     ;Mm;           ;M;,MMMMMMMMMMm;;;;;;.]],
            [[;;;;;;;mmMSSSMMMM,   ;Mm;,   '-    ,;M;MMMMMMMSMMMMm;;;;;;]],
            [[;;;;;;;MMMSSSMMMMMMMm;Mm;;,  ___  ,;SmM;MMMMMMSSMMMM;;;;;;]],
            [[;;'";;;MMMSSSSMMMMMM;MMmS;;,  "  ,;SmMM;MMMMMMSSMMMM;;;;;;]],
            [[!   ;;;MMMSSSSSMMMMM;MMMmSS;;._.;;SSmMM;MMMMMMSSMMMM;;;;;;]],
            [[    ;;;;*MSSSSSSMMMP;Mm*"'q;'   ';p*"*M;MMMMMSSSSMMM;;;;;;]],
            [[    ';;;  ;SS*SSM*M;M;'     `-.        ;;MMMMSSSSSMM;;;;;;]],
            [[     ;;;. ;P  `q; qMM.                 ';MMMMSSSSSMp' ';;;;]],
            [[     ;;;; ',    ; .mm!     \.   `.   /  ;MMM' `qSS'    ';;;]],
            [[     ';;;       ' mmS';     ;     ,  `. ;'M'   `S       ';;]],
            [[      `;;.        mS;;`;    ;     ;    ;M,!     '        ';]],
            [[       ';;       .mS;;, ;   '.    ;    MM;                ;]],
            [[        ';;      MMmS;; `,   ;._.' -_.'MM;                ;]],
            [[         `;;     MMmS;;; ;   ;      ;  MM;                ;]],
            [[           `'.   'MMmS;; `;) ',    .' ,M;'                ;]],
        }

        dashboard.section.header.opts.hl = "AlphaHeader"

        -- Set menu with useful quick actions
        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find file", ":lua require('fzf-lua').files()<CR>"),
            dashboard.button("g", "  Live grep", ":lua require('fzf-lua').live_grep()<CR>"),
            dashboard.button("r", "  Recent", ":lua require('fzf-lua').oldfiles()<CR>"),
            dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }

        -- Set footer
        local function footer()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
                "",
                "Heaven for syntax, Hell for bugs",
                "",
                "⚡ " .. stats.loaded .. " plugins • " .. ms .. "ms",
            }
        end

        dashboard.section.footer.val = footer()
        dashboard.section.footer.opts.hl = "AlphaFooter"

        -- Layout
        dashboard.config.layout = {
            { type = "padding", val = 2 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
        }

        -- Set highlight groups
        vim.cmd [[
            highlight AlphaHeader guifg=#8B00FF
            highlight AlphaFooter guifg=#44475a
        ]]

        -- Disable folding on alpha buffer
        vim.cmd [[
            autocmd FileType alpha setlocal nofoldenable
        ]]

        alpha.setup(dashboard.config)

        -- Disable statusline in alpha
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "alpha",
            callback = function()
                vim.opt_local.laststatus = 0
            end,
        })

        vim.api.nvim_create_autocmd("BufUnload", {
            buffer = 0,
            callback = function()
                vim.opt.laststatus = 3
            end,
        })
    end,
}