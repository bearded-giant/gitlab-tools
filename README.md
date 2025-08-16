# GitLab Tools

Command-line and TUI tools for GitLab pipeline monitoring and exploration.

**Author:** BeardedGiant  
**Repository:** https://github.com/bearded-giant/gitlab-tools  
**License:** Apache License 2.0

## Tools

This repository contains two GitLab tools as submodules:

### [gitlab-cli](https://github.com/bearded-giant/gitlab-cli)
Command-line interface for exploring GitLab pipelines, merge requests, and job statuses.

- Lightweight with minimal dependencies
- Scriptable output for automation
- Pipeline progress tracking
- Failed job analysis

### [gitlab-monitor](https://github.com/bearded-giant/gitlab-monitor)
K9s-style Terminal User Interface for real-time pipeline monitoring.

- Interactive navigation with arrow keys
- Real-time auto-refresh
- Multi-level drill-down (Pipelines → Jobs → Logs)
- Color-coded status indicators

## Installation

### Clone with Submodules

```bash
# Clone repository with submodules
git clone --recursive https://github.com/bearded-giant/gitlab-tools.git

# Or if already cloned
git submodule init
git submodule update
```

### Install Tools

Both tools can be installed independently:

```bash
# Install CLI tool
cd gitlab-cli
pip install .

# Install TUI monitor
cd ../gitlab-monitor
pip install .
```

## Configuration

Both tools use the same environment variables:

```bash
export GITLAB_URL=https://gitlab.example.com
export GITLAB_TOKEN=your_personal_access_token
export GITLAB_PROJECT=group/project
```

## Quick Start

```bash
# CLI - check current branch pipelines
gitlab-cli branch $(git branch --show-current)

# TUI - interactive monitoring
gitlab-monitor
```

## Updating Submodules

To get the latest changes from the submodules:

```bash
git submodule update --remote --merge
```

## Contributing

Each tool has its own repository. Please submit issues and pull requests to the respective repositories:

- [gitlab-cli issues/PRs](https://github.com/bearded-giant/gitlab-cli)
- [gitlab-monitor issues/PRs](https://github.com/bearded-giant/gitlab-monitor)

## License

Copyright 2024 BeardedGiant

Licensed under the Apache License, Version 2.0. See LICENSE file for details.