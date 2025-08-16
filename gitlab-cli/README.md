# GitLab CLI Explorer

A command-line tool for exploring GitLab pipeline and job statuses, designed for interactive exploration and scripting.

## Installation

### Method 1: Install from source (recommended for development)
```bash
# Clone and install in development mode
git clone <repo-url>
cd gitlab-cli
pip install -e .
```

### Method 2: Install as package
```bash
cd gitlab-cli
pip install .
```

### Method 3: Install directly from git
```bash
pip install git+https://github.com/yourusername/gitlab-cli.git
```

## Configuration

### Required Environment Variables
```bash
export GITLAB_URL=https://gitlab.example.com
export GITLAB_TOKEN=your_personal_access_token
export GITLAB_PROJECT=group/project
```

### Alternative: Config File
```bash
# Set configuration via CLI
gitlab-cli config --gitlab-url https://gitlab.example.com
gitlab-cli config --project group/project

# View current configuration
gitlab-cli config --show
```

Configuration is stored in `~/.config/gitlab-cli/config.json`
Cache is stored in `~/.cache/gitlab-cli/`

## Quick Start

After installation, the tool is available as `gitlab-cli` or `gl` (short alias):

```bash
# Get MRs for current branch
gitlab-cli branch $(git branch --show-current)

# Or use the short alias
gl branch $(git branch --show-current)

# Get pipeline status
gl status 123456 --detailed
```

## Commands

### 1. Get MRs for a Branch

```bash
# List all open MRs for current git branch
./pipeline_explorer.py branch $(git branch --show-current)

# List MRs for specific branch
./pipeline_explorer.py branch feature-xyz

# Show all MRs (opened, merged, closed)
./pipeline_explorer.py branch feature-xyz --state all

# Show latest MR and pipeline IDs
./pipeline_explorer.py branch $(git branch --show-current) --latest
```

### 2. Get Pipelines for a Merge Request

```bash
# List all pipelines for MR #1234
./pipeline_explorer.py mr 1234

# Show latest pipeline ID
./pipeline_explorer.py mr 1234 --latest
```

### 2. Get Pipeline Status Summary

```bash
# Show job status summary for pipeline
./pipeline_explorer.py status 567890
```

Shows:
- Total job count
- Status breakdown (success, failed, running, etc.)
- List of failed jobs with details

### 3. List Jobs in a Pipeline

```bash
# List all jobs
./pipeline_explorer.py jobs 567890

# Filter by status
./pipeline_explorer.py jobs 567890 --status failed

# Filter by stage
./pipeline_explorer.py jobs 567890 --stage test

# Sort by duration (longest first)
./pipeline_explorer.py jobs 567890 --sort duration
```

### 4. Get Job Failure Details

```bash
# Show condensed failure info
./pipeline_explorer.py failures 123456

# Show verbose failure details
./pipeline_explorer.py failures 123456 --verbose
```

### 5. Batch Process Failed Jobs

```bash
# Get failures for multiple jobs at once
./pipeline_explorer.py batch-failures 123456 123457 123458
```

## Example Workflows

### Starting from Current Git Branch

```bash
# 1. Find MRs for your current branch
./pipeline_explorer.py branch $(git branch --show-current) --latest

# 2. Get pipelines for the MR (using MR ID from step 1)
./pipeline_explorer.py mr 5678 --latest

# 3. Check status of the pipeline (using pipeline ID from step 2)
./pipeline_explorer.py status 987654

# 4. If there are failures, get details
./pipeline_explorer.py jobs 987654 --status failed
./pipeline_explorer.py failures 111222 --verbose
```

### Automated Pipeline Watching

```bash
# Watch pipeline for current branch (auto-refreshes every 30 seconds)
./watch_pipeline.sh

# Watch with custom refresh interval (10 seconds)
./watch_pipeline.sh 10
```

This will:
1. Find the latest MR for your current git branch
2. Get the latest pipeline for that MR
3. Continuously monitor the pipeline status
4. Show failed job details automatically
5. Stop when pipeline completes

### Manual Workflow

```bash
# 1. Find pipelines for your MR
./pipeline_explorer.py mr 5678

# 2. Check status of the latest pipeline (e.g., 987654)
./pipeline_explorer.py status 987654

# 3. List failed jobs in that pipeline
./pipeline_explorer.py jobs 987654 --status failed

# 4. Get details on specific failed job
./pipeline_explorer.py failures 111222 --verbose

# 5. Or check multiple failed jobs at once
./pipeline_explorer.py batch-failures 111222 111223 111224
```

## Features

- **Color-coded output**: Success (green), Failed (red), Running (yellow)
- **Caching**: Completed pipelines are cached locally for faster access
- **Filtering**: Filter jobs by status or stage
- **Sorting**: Sort jobs by duration, name, or creation time
- **Batch processing**: Analyze multiple failed jobs at once
- **Detailed failure extraction**: Automatically extracts test failures, stderr, and error messages

## Output Examples

### Pipeline Status
```
Pipeline 567890 Job Summary:
----------------------------------------
Total Jobs:    142
  ✅ Success:  130
  ❌ Failed:   5
  🔄 Running:  2
  ⏸  Pending:  3
  ⏭  Skipped:  2
  🚫 Canceled: 0
  👤 Manual:   0

Failed Jobs:
------------------------------------------------------------
ID           Stage           Name                                     Duration
------------------------------------------------------------
123456       test            py311 integration test parallel 1/100   5m32s
123457       test            py311 integration test parallel 15/100  4m18s
```

### Job Failures (Condensed)
```
Job 123456: py311 integration test parallel 1/100
Status: failed | Stage: test
Duration: 5m32s
URL: https://gitlab.rechargeapps.net/...

📋 Test Failures:
  • FAILED tests/api/test_checkout.py::test_create_checkout
  • FAILED tests/api/test_checkout.py::test_update_checkout
```