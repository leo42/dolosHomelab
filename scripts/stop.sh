#!/bin/bash

# Stop Script for Dolos Homelab
# Gracefully stops both mainnet and preprod nodes

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

echo "=========================================="
echo "Stopping Dolos Nodes"
echo "=========================================="
echo ""

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if containers are running
MAINNET_RUNNING=$(docker ps --format '{{.Names}}' | grep -c "^dolos-mainnet$" || true)
PREPROD_RUNNING=$(docker ps --format '{{.Names}}' | grep -c "^dolos-preprod$" || true)

if [ "$MAINNET_RUNNING" -eq 0 ] && [ "$PREPROD_RUNNING" -eq 0 ]; then
    echo -e "${YELLOW}No nodes are currently running.${NC}"
    exit 0
fi

echo -e "${BLUE}Stopping nodes...${NC}"

# Stop containers using docker-compose
if docker-compose stop; then
    echo ""
    echo -e "${GREEN}✓ Nodes stopped successfully!${NC}"
    echo ""
    echo "To remove containers (and volumes):"
    echo "  docker-compose down"
    echo ""
    echo "To remove containers and volumes:"
    echo "  docker-compose down -v"
    echo ""
    echo "Note: Removing volumes will delete blockchain data."
else
    echo -e "${RED}Failed to stop nodes${NC}"
    exit 1
fi

