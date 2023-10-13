local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "theme_check", "emmet_ls", "marksman", "tailwindCSS" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- setup emmet for liquid
lspconfig.emmet_ls.setup({
    filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'liquid' },
    init_options = {
      html = {
        options = {
          -- for possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#l79-l267
          ["bem.enabled"] = true,
        },
      },
    }
})

-- 
-- lspconfig.pyright.setup { blabla}
