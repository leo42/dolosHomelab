#!/bin/bash

# Download Genesis Files Script
# Downloads all required genesis files and configuration files for Cardano nodes
# from official Cardano sources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URLs for Cardano configuration files
MAINNET_BASE_URL="https://book.world.dev.cardano.org/environments/mainnet"
PREPROD_BASE_URL="https://book.world.dev.cardano.org/environments/preprod"

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration directories
MAINNET_CONFIG_DIR="$PROJECT_ROOT/config/mainnet"
PREPROD_CONFIG_DIR="$PROJECT_ROOT/config/preprod"

# Files to download for each network
FILES=("config.json" "topology.json" "byron-genesis.json" "shelley-genesis.json" "alonzo-genesis.json" "conway-genesis.json")

# Function to download files for a network
download_network_files() {
    local network=$1
    local base_url=$2
    local config_dir=$3
    
    echo -e "${GREEN}Downloading files for ${network} network...${NC}"
    echo "  Base URL: $base_url"
    echo "  Target directory: $config_dir"
    
    # Create directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Download each file
    for file in "${FILES[@]}"; do
        local url="${base_url}/${file}"
        local output_file="${config_dir}/${file}"
        
        echo -n "  Downloading $file... "
        
        if curl -sSLf -o "$output_file" "$url"; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ Failed${NC}"
            echo -e "${YELLOW}Warning: Failed to download $file from $url${NC}"
            # Continue with other files even if one fails
        fi
    done
    
    # Verify required files exist
    local required_files=("config.json" "topology.json" "shelley-genesis.json" "alonzo-genesis.json")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${config_dir}/${file}" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required files for ${network}:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "  ${RED}- $file${NC}"
        done
        return 1
    else
        echo -e "${GREEN}✓ All required files downloaded for ${network}${NC}"
        return 0
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Downloading Cardano Genesis Files"
    echo "=========================================="
    echo ""
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed.${NC}"
        echo "Please install curl: sudo apt-get install curl"
        exit 1
    fi
    
    # Download mainnet files
    if ! download_network_files "mainnet" "$MAINNET_BASE_URL" "$MAINNET_CONFIG_DIR"; then
        echo -e "${RED}Failed to download mainnet files${NC}"
        exit 1
    fi
    
    echo ""
    
    # Download preprod files
    if ! download_network_files "preprod" "$PREPROD_BASE_URL" "$PREPROD_CONFIG_DIR"; then
        echo -e "${RED}Failed to download preprod files${NC}"
        exit 1
    fi
    
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✓ All files downloaded successfully!${NC}"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Verify config.json files reference genesis files correctly"
    echo "  2. Run './scripts/setup.sh' to complete setup"
    echo "  3. Run './scripts/start.sh' to start the nodes"
}

# Run main function
main "$@"

