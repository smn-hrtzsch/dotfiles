# To-Do

- [x] Add `/ship` command for OpenCode, Gemini/Antigravity CLI, and Codex
  - [x] Create `opencode/.opencode/commands/ship.md`
  - [x] Create `gemini/.gemini/commands/ship.toml`
  - [x] Create `codex/.codex/skills/opencode-ship/SKILL.md`
  - [x] Update `nix/modules/common.nix` to link and manage `opencode-ship`
  - [x] Rebuild system configuration and verify setup

- [x] Link custom skills/commands to Antigravity CLI
  - [x] Add symlinks for `opencode-*` skills to `.gemini/antigravity-cli/skills/` in `nix/modules/common.nix`
  - [x] Rebuild and verify they appear in the skills menu
