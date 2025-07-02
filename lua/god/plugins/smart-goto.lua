return {
    -- Better go to definition that skips imports
    {
        "rmagatti/goto-preview",
        config = function()
            require('goto-preview').setup({
                width = 120,
                height = 25,
                default_mappings = false,
                debug = false,
                opacity = nil,
                post_open_hook = nil,
            })
        end,
    },
    
    -- Configuration for smart navigation
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            -- Override LSP navigation mappings
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('SmartGoToDefinition', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    
                    -- Smart go to definition that tries multiple strategies
                    map('gd', function()
                        -- First, try telescope/fzf-lua lsp_definitions
                        local has_fzf, fzf = pcall(require, 'fzf-lua')
                        if has_fzf then
                            -- Get the current word under cursor
                            local word = vim.fn.expand('<cword>')
                            
                            -- Try to get all definitions
                            local params = vim.lsp.util.make_position_params()
                            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
                                if err then
                                    vim.notify('Error getting definitions: ' .. err.message, vim.log.levels.ERROR)
                                    return
                                end
                                
                                if not result or vim.tbl_isempty(result) then
                                    -- Fallback to type definition if no definition found
                                    vim.lsp.buf.type_definition()
                                    return
                                end
                                
                                -- If result is a single location
                                if result.uri or result.targetUri then
                                    result = { result }
                                end
                                
                                -- Filter out import statements
                                local filtered_results = {}
                                for _, location in ipairs(result) do
                                    local uri = location.uri or location.targetUri
                                    local range = location.range or location.targetSelectionRange
                                    
                                    -- Check if this is likely an import by examining the line
                                    local bufnr = vim.uri_to_bufnr(uri)
                                    vim.fn.bufload(bufnr)
                                    local lines = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)
                                    
                                    if #lines > 0 then
                                        local line = lines[1]
                                        -- Skip if line contains import/require/use statements
                                        local is_import = line:match('^%s*import%s+') or
                                                        line:match('^%s*from%s+') or
                                                        line:match('^%s*const%s+.*=%s*require') or
                                                        line:match('^%s*use%s+') or
                                                        line:match('^%s*#include%s+')
                                        
                                        if not is_import then
                                            table.insert(filtered_results, location)
                                        end
                                    end
                                end
                                
                                -- If we filtered out all results, use original results
                                if #filtered_results == 0 then
                                    filtered_results = result
                                end
                                
                                -- If only one result, jump directly
                                if #filtered_results == 1 then
                                    -- Use the newer vim.lsp.util.show_document API
                                    local location = filtered_results[1]
                                    local uri = location.uri or location.targetUri
                                    local range = location.range or location.targetSelectionRange
                                    
                                    vim.lsp.util.show_document({
                                        uri = uri,
                                        selection = range,
                                    }, 'utf-8')
                                else
                                    -- Multiple results, use fzf-lua to choose
                                    fzf.lsp_definitions({ 
                                        jump_to_single_result = true,
                                        ignore_current_line = true,
                                    })
                                end
                            end)
                        else
                            -- Fallback to regular definition
                            vim.lsp.buf.definition()
                        end
                    end, '[G]oto [D]efinition (Smart)')
                    
                    -- Preview definition without jumping
                    map('gpd', function()
                        require('goto-preview').goto_preview_definition()
                    end, '[G]oto [P]review [D]efinition')
                    
                    -- Other preview mappings
                    map('gpr', function()
                        require('goto-preview').goto_preview_references()
                    end, '[G]oto [P]review [R]eferences')
                    
                    map('gpi', function()
                        require('goto-preview').goto_preview_implementation()
                    end, '[G]oto [P]review [I]mplementation')
                    
                    map('gpt', function()
                        require('goto-preview').goto_preview_type_definition()
                    end, '[G]oto [P]review [T]ype Definition')
                    
                    -- Close preview window
                    map('gP', function()
                        require('goto-preview').close_all_win()
                    end, 'Close all preview windows')
                    
                    -- Alternative: jump to implementation instead of definition
                    map('gD', vim.lsp.buf.implementation, '[G]oto Implementation (Alternative)')
                end,
            })
            
            return opts
        end,
    },
}