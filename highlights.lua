-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}

---@type Base46HLGroupsList
M.override = {
  Comment = {
    italic = true,
  },
  Substitute = {
    -- bg = "dark_red",
    -- bg = "sapphire",
    -- bg = "#45475a",
    bg = "sun",
    fg = "#181825",
    bold = true,
  },
  Cursor = {
    bg = "blue",
  },
  IncSearch = {
    bg = "#89dceb",
    fg = "#181825"
  },
  Visual = {
    bg = "grey_fg2",
  },
  Search = {
    bg = "red",
  },
}

---@type HLTable
M.add = {
  MiniPickMatchCurrent = {
    -- bg = "#f5bde6",
    -- fg = "black"
    bg = "#585b70"
  },
  MiniPickPreviewLine = {
    bg = "#585b70"
  },
  NvimTreeOpenedFolderName = { fg = "green", bold = true },
  OrgAgendaScheduled = {
    fg = "#7dc4e4",
  },
  OrgAgendaScheduledPast = {
    fg = "#cad3f5",
  },
  OrgAgendaDeadline = {
    fg = "#f5bde6",
  },
  OrgAgendaDay = {
    fg = "#939ab7",
  },
  OrgTSHeadlinelevel2 = {
    fg = "#c6a0f6",
  },
  OrgTSHeadlinelevel3 = {
    fg = "#a6da95",
  },
  OrgTSHeadlinelevel4 = {
    fg = "#ee99a0",
  },
  OrgTSHeadlinelevel5 = {
    fg = "#91d7e3",
  },
  OrgTSPlan = {
    fg = "#eed49f",
  },
  OrgTSCheckbox = {
    fg = "#a5adcb",
  },
  OrgTSTag = {
    fg = "#f5a97f",
  },
  DiffviewDiffAdd = {
    bg = "#283B4D",
    fg = "NONE"
  },
  DiffviewDiffChange = {
    bg = "#283B4D",
    fg = "NONE"
  },
  DiffviewDiffDelete = {
    bg = "#3C2C3C",
    fg = "#4d384d"
  },
  DiffviewDiffText = {
    bg = "#365069",
    fg = "NONE"
  },
  NeogitDiffAdd = {
    bg = "#283B4D",
    fg = "NONE"
  },
  NeogitDiffChange = {
    bg = "#283B4D",
    fg = "NONE"
  },
  NeogitDiffDelete = {
    bg = "#3C2C3C",
    fg = "#4d384d"
  },
  NeogitDiffText = {
    bg = "#365069",
    fg = "NONE"
  }
}

return M
