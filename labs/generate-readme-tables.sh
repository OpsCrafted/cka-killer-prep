#!/bin/bash
# Generate README scenario tables from scenario metadata
# Usage: ./labs/generate-readme-tables.sh > /tmp/scenario-table.md

set -e

LABS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="$LABS_DIR/scenarios"

# Extract scenario title from folder name (e.g., s01-api-server-down -> api-server-down)
get_title() {
    local folder=$1
    echo "$folder" | sed 's/^s[0-9]*-//'
}

# Map domain names to CKA exam domains
map_domain() {
    local domain=$1
    case "$domain" in
        troubleshooting) echo "Troubleshooting" ;;
        cluster-architecture) echo "Cluster Architecture" ;;
        rbac-security) echo "Cluster Architecture" ;;
        networking) echo "Services & Networking" ;;
        workloads) echo "Workloads & Scheduling" ;;
        storage) echo "Storage" ;;
        *) echo "$domain" ;;
    esac
}

# Generate table with all scenarios grouped by section
echo "| Scenario | Topic | Domain | Status |"
echo "|----------|-------|--------|--------|"

last_group=""
s_num=0

for scenario_dir in "$SCENARIOS_DIR"/s*; do
    if [ ! -d "$scenario_dir" ]; then
        continue
    fi

    folder=$(basename "$scenario_dir")
    num=$(echo "$folder" | sed 's/^s0*//' | sed 's/-.*//')
    title=$(get_title "$folder")

    # Read metadata
    if [ -f "$scenario_dir/meta.yaml" ]; then
        domain=$(grep "^domain:" "$scenario_dir/meta.yaml" | cut -d' ' -f2)
        status=$(grep "^status:" "$scenario_dir/meta.yaml" | cut -d' ' -f2)
    else
        domain="unknown"
        status="unknown"
    fi

    # Map to CKA domains
    cka_domain=$(map_domain "$domain")

    # Determine group
    if [ "$num" -le 12 ]; then
        group="Troubleshooting"
    elif [ "$num" -le 20 ]; then
        group="Cluster Architecture"
    elif [ "$num" -le 30 ]; then
        group="Services & Networking"
    elif [ "$num" -le 36 ]; then
        group="Workloads & Scheduling"
    else
        group="Storage"
    fi

    # Print group header when it changes
    if [ "$group" != "$last_group" ]; then
        echo "| **$group** | | | |"
        last_group="$group"
    fi

    # Status icon
    if [ "$status" = "ready" ]; then
        status_icon="✓"
    else
        status_icon="◐"
    fi

    # Print scenario row
    printf "| %s | %s | %s | %s |\n" "$folder" "$title" "$cka_domain" "$status_icon"
done

echo ""
echo "Run all 40: \`bash labs/test-all.sh\`"
echo "Run single: \`./labs/run.sh 01\`"
echo "Verify: \`./labs/run.sh verify 01\`"
