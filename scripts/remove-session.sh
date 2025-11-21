#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/variables.sh"
source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/spinner_helpers.sh"


# delimiters
d=$'\t'
delimiter=$'\t'


# Target file for saving the session
SAVED_SESSIONS_FILE="$TMUX_HOME/resurrect/saved_sessions.tmux"

# Check if session name parameter was provided
if [ $# -ne 1 ]; then
    usage
fi

TARGET_SESSION="$1"


show_output() {
	[ "$SCRIPT_OUTPUT" != "quiet" ]
}

# Function to remove existing session data from the file
remove_existing_session() {
	local session_name="$1"
	local temp_file=$(mktemp)

	# If file doesn't exist, create an empty one
	if [ ! -f "$SAVED_SESSIONS_FILE" ]; then
		touch "$SAVED_SESSIONS_FILE"
		return 0
	fi

	# Filter out lines that contain the current session name
	grep -v "${d}${session_name}${d}" "$SAVED_SESSIONS_FILE" > "$temp_file" || true
	cat "$temp_file" > "$SAVED_SESSIONS_FILE"
	rm "$temp_file"
}

main() {
	if supported_tmux_version_ok; then
		if show_output; then
			start_spinner "Removing session '${TARGET_SESSION}' current session..." "Session removed!"
		fi
		remove_existing_session $TARGET_SESSION
		if show_output; then
			stop_spinner
			display_message "Session $TARGET_SESSION removed"
		fi
	fi
}
main
