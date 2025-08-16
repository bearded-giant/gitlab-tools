#!/bin/bash

# Helper script to watch pipeline status from current git branch
# Usage: ./watch_pipeline.sh [refresh_interval_seconds]

REFRESH_INTERVAL=${1:-30}  # Default 30 seconds

# Get current branch
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    echo "Error: Not in a git repository or cannot determine branch"
    exit 1
fi

echo "🔍 Finding MRs for branch: $BRANCH"
echo ""

# Get MRs for current branch
MR_OUTPUT=$(./pipeline_explorer.py branch "$BRANCH" --latest 2>&1)
echo "$MR_OUTPUT"

# Extract MR ID from output
MR_ID=$(echo "$MR_OUTPUT" | grep "Latest MR:" | sed -n 's/.*!\([0-9]*\).*/\1/p')

if [ -z "$MR_ID" ]; then
    echo ""
    echo "❌ No open MR found for branch: $BRANCH"
    echo "   Create an MR first or specify MR ID manually:"
    echo "   ./pipeline_explorer.py mr <mr_id>"
    exit 1
fi

# Extract pipeline ID from output
PIPELINE_ID=$(echo "$MR_OUTPUT" | grep "Latest pipeline:" | sed -n 's/.*Latest pipeline: \([0-9]*\).*/\1/p')

if [ -z "$PIPELINE_ID" ]; then
    echo ""
    echo "⚠️  No pipeline found for MR !$MR_ID"
    echo "   Waiting for pipeline to be created..."
    
    # Poll for pipeline creation
    while [ -z "$PIPELINE_ID" ]; do
        sleep 5
        PIPELINE_OUTPUT=$(./pipeline_explorer.py mr "$MR_ID" --latest 2>&1)
        PIPELINE_ID=$(echo "$PIPELINE_OUTPUT" | grep "Latest pipeline:" | sed -n 's/.*Latest pipeline: \([0-9]*\).*/\1/p')
    done
    echo "✅ Pipeline created: $PIPELINE_ID"
fi

echo ""
echo "📊 Watching pipeline $PIPELINE_ID (refreshing every ${REFRESH_INTERVAL}s)"
echo "   Press Ctrl+C to stop"
echo ""
echo "=" | sed 's/./-/g'

# Watch pipeline status
while true; do
    clear
    echo "🔄 Pipeline $PIPELINE_ID for MR !$MR_ID on branch: $BRANCH"
    echo "   Last update: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Get pipeline status (detailed view for better progress tracking)
    ./pipeline_explorer.py status "$PIPELINE_ID" --detailed
    
    # Check if there are failed jobs
    FAILED_JOBS=$(./pipeline_explorer.py jobs "$PIPELINE_ID" --status failed 2>&1 | grep -E "^[0-9]+" | awk '{print $1}')
    
    if [ ! -z "$FAILED_JOBS" ]; then
        echo ""
        echo "❌ Failed Jobs Details:"
        echo "-" | sed 's/./=/g'
        for JOB_ID in $FAILED_JOBS; do
            ./pipeline_explorer.py failures "$JOB_ID" 2>&1 | head -20
            echo ""
        done
    fi
    
    # Check completion status
    STATUS=$(./pipeline_explorer.py status "$PIPELINE_ID" 2>&1 | grep -E "Running:|Pending:" | grep -E "[1-9]")
    if [ -z "$STATUS" ]; then
        echo ""
        echo "✅ Pipeline completed!"
        break
    fi
    
    sleep "$REFRESH_INTERVAL"
done