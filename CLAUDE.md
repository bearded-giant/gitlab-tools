# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a **parent repository** containing two independent GitLab tools as **git submodules**:

| Submodule | Command | Purpose | UI |
|-----------|---------|---------|-----|
| `gitlab-cli/` | `gl` / `gitlab-cli` | CLI for pipelines, MRs, jobs, code search | Plain terminal output |
| `gitlab-monitor/` | `glmon` / `gitlab-monitor` | K9s-style TUI for real-time pipeline monitoring | Textual TUI |

Each submodule is an independent Python package with its own setup, dependencies, and (in gitlab-cli's case) its own CLAUDE.md. There are no cross-dependencies between them.

## Common Commands

```bash
# clone with submodules
git clone --recursive https://github.com/bearded-giant/gitlab-tools.git

# initialize submodules after clone
git submodule init && git submodule update

# pull latest submodule changes
git submodule update --remote --merge

# install each tool (from respective dirs)
cd gitlab-cli && pipx install -e . && cd ..
cd gitlab-monitor && pipx install -e . && cd ..
```

### gitlab-cli tests (manual scripts, no framework)
```bash
cd gitlab-cli
python test_cli_v3.py        # CLI parsing
python test_cache.py          # cache performance
python test_git_detection.py  # git remote URL parsing
```

### gitlab-monitor tests
```bash
cd gitlab-monitor && make test   # pytest via uv; test_*.py
```

## Shared Configuration

Both tools use the same environment variables:
- `GITLAB_URL` - GitLab instance URL
- `GITLAB_TOKEN` - Personal access token
- `GITLAB_PROJECT` - Default project path (e.g., `group/subgroup/project`)

Both support config files in `~/.config/<tool-name>/config.json`.

## Architecture Notes

### gitlab-cli (`gl`)
- **Entry point**: `gitlab_cli/cli_v3.py` routes commands to handlers in `gitlab_cli/commands/`
- **Two CLI layers**: Legacy `cli.py` (contains `GitLabExplorer` class with caching/API logic) + modern `cli_v3.py` (argparse routing to command objects)
- **Command pattern**: Each command inherits `BaseCommand`, implements `add_arguments()` + `handle()`, supports friendly/table/json output formats
- **Caching**: SQLite at `~/.cache/gitlab-cli/pipelines_cache.db`, only caches completed pipelines
- **Git detection**: Auto-extracts project from `git remote` URL, validates domain against configured `GITLAB_URL`
- **Single dependency**: `python-gitlab>=3.0.0`
- **See**: `gitlab-cli/CLAUDE.md` for detailed command patterns and API usage

### gitlab-monitor (`glmon`)
- **Entry point**: `gitlab_monitor/tui.py:main()`
- **Home**: `MyWorkScreen` (cross-project: favorite repos + my open MRs grouped by source branch). It's the default landing and module 1 (no last-view restore — always opens here). `<esc>`/`C-c` quit the app; `q` is back-only (no-op with a hint on home screens). Explicit `-p`/`GITLAB_PROJECT` skips it and opens that project's pipelines.
- **Screen hierarchy**: `MyWorkScreen` → `ProjectHubScreen` / `MergeRequestDetailScreen`; `ProjectSelectScreen` → `PipelineListScreen` → `JobListScreen` → `JobDetailScreen` / `FailedJobsScreen`; MR side: `MyMergeRequestsScreen` / `ProjectMergeRequestsScreen` → `MergeRequestDetailScreen`
- **Key dispatch**: screens do NOT use Textual `BINDINGS`. `ScreenBase.on_key` reads per-screen `KEY_MAP = {key: action}` dict → calls `action_{name}`. Keys case-sensitive (`"a"` ≠ `"A"`).
- **API wrapper**: `GitLabAPI` (`api.py`) wraps python-gitlab calls
- **Styling**: Catppuccin Mocha theme via Textual CSS
- **Dependencies**: `python-gitlab>=3.0.0`, `textual>=0.41.0`, `rich>=13.0.0`
- **Module layout**: `tui.py` (screens/app, ~4500 lines), `api.py` (`GitLabAPI`), `formatting.py` (Rich text/badge helpers), `config.py`, `constants.py`
- **Background jobs**: `reviewd.py` (`glmon-reviewd`, review poller) and `jirad.py` (`glmon-jirad`, Jira ticket per MR); both run under launchd from `launchd/`

## Working with Submodules

When making changes, work inside the submodule directory. Each submodule has its own git history and remote. Commits in a submodule update the parent repo's submodule pointer (visible as a change to the submodule path in `git status`).

```bash
# commit submodule changes
cd gitlab-cli
git add . && git commit -m "change description"
git push

# then update parent pointer
cd ..
git add gitlab-cli
git commit -m "update gitlab-cli submodule"
```
