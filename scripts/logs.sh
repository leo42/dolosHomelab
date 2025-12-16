#!/bin/bash

# Logs Script for Dolos Homelab
# View logs from mainnet, preprod, or both nodes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Usage function
usage() {
    echo "Usage: $0 [mainnet|preprod|all] [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --follow    Follow log output (like tail -f)"
    echo "  -n, --lines N   Number of lines to show (default: 100)"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 mainnet              # Show last 100 lines from mainnet"
    echo "  $0 preprod -f           # Follow preprod logs"
    echo "  $0 all -n 50            # Show last 50 lines from both"
    exit 1
}

# Default values
NODE=""
FOLLOW=false
LINES=100

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        mainnet|preprod|all)
            NODE="$1"
            shift
            ;;
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Check if node is specified
if [ -z "$NODE" ]; then
    echo -e "${RED}Error: Please specify a node (mainnet, preprod, or all)${NC}"
    echo ""
    usage
fi

# Navigate to project root
cd "$PROJECT_ROOT"

# Function to show logs for a node
show_logs() {
    local container=$1
    local name=$2
    
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        echo -e "${YELLOW}Warning: ${container} is not running${NC}"
        return 1
    fi
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Logs for ${name} (${container})${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if [ "$FOLLOW" = true ]; then
        docker logs -f "$container"
    else
        docker logs --tail "$LINES" "$container"
    fi
}

# Show logs based on selection
case $NODE in
    mainnet)
        show_logs "dolos-mainnet" "Mainnet"
        ;;
    preprod)
        show_logs "dolos-preprod" "Preprod"
        ;;
    all)
        if [ "$FOLLOW" = true ]; then
            echo -e "${YELLOW}Note: Following logs from multiple containers.${NC}"
            echo -e "${YELLOW}Press Ctrl+C to stop.${NC}"
            echo ""
            docker compose logs -f
        else
            show_logs "dolos-mainnet" "Mainnet"
            echo ""
            show_logs "dolos-preprod" "Preprod"
        fi
        ;;
    *)
        echo -e "${RED}Invalid node: $NODE${NC}"
        usage
        ;;
esac

