#!/bin/bash
# setup_project.sh
#
# Creates the directory structure for the
# satellite_sync_plan_weekly_enforcement Ansible role.
#
# Usage:
#   chmod +x setup_project.sh
#   ./setup_project.sh [target_directory]
#
# If no target directory is specified, creates in current directory.

set -e

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"

echo "Creating project structure in: ${TARGET_DIR}"

mkdir -p "${TARGET_DIR}/collections"
mkdir -p "${TARGET_DIR}/group_vars"
mkdir -p "${TARGET_DIR}/playbooks"
mkdir -p "${TARGET_DIR}/roles/satellite_sync_plan_weekly_enforcement/defaults"
mkdir -p "${TARGET_DIR}/roles/satellite_sync_plan_weekly_enforcement/tasks"

echo "Done. Directory structure created:"
find "${TARGET_DIR}" -type d | sort