#!/bin/bash

# Start Script for Dolos Homelab
# Starts both mainnet and preprod nodes with validation

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
echo "Starting Dolos Nodes"
echo "=========================================="
echo ""

# Function to validate genesis files exist
validate_network_config() {
    local network=$1
    local config_dir="$PROJECT_ROOT/config/$network"
    
    local required_files=("config.json" "topology.json" "shelley-genesis.json" "alonzo-genesis.json")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$config_dir/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required files for ${network}:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "  ${RED}- $file${NC}"
        done
        echo ""
        echo "Run './scripts/setup.sh' to download required files."
        return 1
    fi
    return 0
}

# Validate configurations
echo -e "${BLUE}Validating configurations...${NC}"
if ! validate_network_config "mainnet"; then
    exit 1
fi
if ! validate_network_config "preprod"; then
    exit 1
fi
echo -e "${GREEN}✓ All configurations valid${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker and try again."
    exit 1
fi

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if containers are already running
if docker ps --format '{{.Names}}' | grep -q "^dolos-mainnet$"; then
    echo -e "${YELLOW}Warning: dolos-mainnet is already running${NC}"
    read -p "Stop and restart? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop dolos-mainnet
        docker rm dolos-mainnet
    else
        echo "Skipping mainnet node."
    fi
fi

if docker ps --format '{{.Names}}' | grep -q "^dolos-preprod$"; then
    echo -e "${YELLOW}Warning: dolos-preprod is already running${NC}"
    read -p "Stop and restart? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop dolos-preprod
        docker rm dolos-preprod
    else
        echo "Skipping preprod node."
    fi
fi

echo ""
echo -e "${BLUE}Starting nodes...${NC}"

# Start containers using docker-compose
if docker-compose up -d; then
    echo ""
    echo -e "${GREEN}✓ Nodes started successfully!${NC}"
    echo ""
    echo "Status:"
    docker-compose ps
    echo ""
    echo "To view logs:"
    echo "  ./scripts/logs.sh mainnet"
    echo "  ./scripts/logs.sh preprod"
    echo "  ./scripts/logs.sh all"
    echo ""
    echo "To stop nodes:"
    echo "  ./scripts/stop.sh"
else
    echo -e "${RED}Failed to start nodes${NC}"
    exit 1
fi

