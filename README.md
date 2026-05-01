# Neovim Configuration Cheatsheet

This configuration is modular and uses **Lazy.nvim** for plugin management.

## 🚀 Core Shortcuts
| Key | Action |
|-----|--------|
| `<leader>pv` | Open File Explorer (Netrw) |
| `jk` | Escape Insert Mode |
| `<Esc>u` | Clear search highlight |
| `<leader>y` | Copy to System Clipboard (Visual/Normal) |
| `<leader>Y` | Copy Line to System Clipboard |
| `<leader>p` | Paste over selection (keep buffer) |

## 🔍 Telescope (Search)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find Files |
| `<leader>fg` | Live Grep (Search text) |
| `<leader>fb` | List Buffers |
| `<leader>fh` | Help Tags |

## 🛠️ LSP & Diagnostics
| Key | Action |
|-----|--------|
| `gd` | Go to Definition (Telescope picker) |
| `gD` | Go to Definition (open in new tab) |
| `gr` | Show References |
| `K` | Show Documentation (Hover) |
| `<leader>ca` | Code Actions |
| `<leader>rn` | Rename Symbol |
| `[d` / `]d` | Prev/Next Diagnostic |
| `<leader>fd` | Format Buffer |
| `<leader>de` | Show Diagnostic at Cursor (floating window) |
| `<leader>dt` | Toggle Inline Diagnostics (virtual text) |
| `:FormatToggle` | Toggle Autoformat on Save |

## 🤖 AI (CodeCompanion + Gemini)
| Key | Action |
|-----|--------|
| `<leader>gc` | Toggle Gemini Chat |
| `<leader>ga` | AI Actions Menu |
| `<leader>ge` | (Visual) Explain selected code |
| `<leader>gf` | (Visual) Fix selected code |
| `<leader>gd` | Generate Documentation/Comments |

## 📑 Tabs & Navigation
| Key | Action |
|-----|--------|
| `<M-1>`..`9` | Switch to Tab 1-9 (Alt+1..9) |
| `<M-0>` | Switch to last Tab |
| `<leader>tn` | New Tab |
| `<leader>to` | Close Other Tabs |
| `<leader>tx` | Close Current Tab |
| `<leader>ts` | Move Current Window to New Tab |
| `<leader>tH` | Move Tab Left |
| `<leader>tL` | Move Tab Right |

## 📂 Folding (UFO)
| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zp` | Peek into fold (fallback: hover) |

## 💻 Terminal & Tools
| Key | Action |
|-----|--------|
| `zx` | Exit Terminal Mode |
| `<leader>tt` | Toggle Floating Terminal |
| `<leader>th` | Horizontal Terminal |
| `<leader>tv` | Vertical Terminal |
| `<leader>gg` | Open LazyGit (float) |
| `<leader>mp` | Toggle Markdown Preview |

## 📝 Visual Mode
| Key | Action |
|-----|--------|
| `J` / `K` | Move Selected Lines Down / Up |
| `>` / `<` | Indent Right / Left (keep selection) |

---
*Note: This configuration requires the `GEMINI_API_KEY` environment variable to be set for AI features.*
