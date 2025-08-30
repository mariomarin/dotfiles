#!/bin/bash
# This script preserves the feedbackSurveyState.lastShownTime value
# while updating other parts of the settings.json file

# Read the current timestamp from the target file if it exists
if [ -f "$HOME/.claude/settings.json" ]; then
    CURRENT_TIME=$(jq -r '.feedbackSurveyState.lastShownTime // empty' "$HOME/.claude/settings.json" 2> /dev/null)
fi

# Read from stdin (the chezmoi-managed content)
CONTENT=$(cat)

# If we have a current timestamp, preserve it
if [ -n "$CURRENT_TIME" ]; then
    echo "$CONTENT" | jq ".feedbackSurveyState.lastShownTime = $CURRENT_TIME"
else
    echo "$CONTENT"
fi
