#!/bin/bash

# Setup Script for Dolos Homelab
# This script initializes the directory structure, downloads genesis files,
# and prepares the environment for running Dolos nodes

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
echo "Dolos Homelab Setup"
echo "=========================================="
echo ""

# Check for required commands
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is required but not installed.${NC}"
        return 1
    fi
    return 0
}

echo -e "${BLUE}Checking prerequisites...${NC}"
MISSING_DEPS=0

if ! check_command "docker"; then
    echo "  Install Docker: https://docs.docker.com/get-docker/"
    MISSING_DEPS=1
fi

# Check for docker compose (V2 plugin)
if ! docker compose version > /dev/null 2>&1; then
    echo -e "${RED}Error: docker compose is required but not installed.${NC}"
    echo "  Install Docker Compose plugin: https://docs.docker.com/compose/install/linux/"
    MISSING_DEPS=1
fi

if ! check_command "curl"; then
    echo "  Install curl: sudo apt-get install curl"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${RED}Please install missing dependencies and run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Create .env file if it doesn't exist
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${BLUE}Creating .env file from .env.example...${NC}"
    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
        echo -e "${GREEN}✓ .env file created${NC}"
        echo -e "${YELLOW}Note: You can edit .env to customize settings${NC}"
    else
        echo -e "${YELLOW}Warning: .env.example not found, skipping .env creation${NC}"
    fi
    echo ""
fi

# Create directory structure
echo -e "${BLUE}Creating directory structure...${NC}"
mkdir -p "$PROJECT_ROOT/config/mainnet"
mkdir -p "$PROJECT_ROOT/config/preprod"
mkdir -p "$PROJECT_ROOT/data/mainnet"
mkdir -p "$PROJECT_ROOT/data/preprod"
mkdir -p "$PROJECT_ROOT/scripts"
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Set permissions for data directories
echo -e "${BLUE}Setting directory permissions...${NC}"
chmod 755 "$PROJECT_ROOT/data/mainnet"
chmod 755 "$PROJECT_ROOT/data/preprod"
chmod 755 "$PROJECT_ROOT/config/mainnet"
chmod 755 "$PROJECT_ROOT/config/preprod"
echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

# Download genesis files
echo -e "${BLUE}Downloading genesis files...${NC}"
if [ -f "$SCRIPT_DIR/download-genesis.sh" ]; then
    bash "$SCRIPT_DIR/download-genesis.sh"
else
    echo -e "${RED}Error: download-genesis.sh not found${NC}"
    exit 1
fi

# Validate genesis files
echo ""
echo -e "${BLUE}Validating configuration files...${NC}"
VALIDATION_ERRORS=0

check_genesis_file() {
    local network=$1
    local file=$2
    local filepath="$PROJECT_ROOT/config/$network/$file"
    
    if [ ! -f "$filepath" ]; then
        echo -e "  ${RED}✗ Missing: $network/$file${NC}"
        return 1
    elif [ ! -s "$filepath" ]; then
        echo -e "  ${RED}✗ Empty: $network/$file${NC}"
        return 1
    else
        echo -e "  ${GREEN}✓ Found: $network/$file${NC}"
        return 0
    fi
}

# Check required files for mainnet
if ! check_genesis_file "mainnet" "config.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "mainnet" "topology.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "mainnet" "shelley-genesis.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "mainnet" "alonzo-genesis.json"; then VALIDATION_ERRORS=1; fi

# Check required files for preprod
if ! check_genesis_file "preprod" "config.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "preprod" "topology.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "preprod" "shelley-genesis.json"; then VALIDATION_ERRORS=1; fi
if ! check_genesis_file "preprod" "alonzo-genesis.json"; then VALIDATION_ERRORS=1; fi

if [ $VALIDATION_ERRORS -eq 1 ]; then
    echo -e "${RED}Validation failed. Please check the errors above.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All required files validated${NC}"
echo ""

# Check disk space
echo -e "${BLUE}Checking disk space...${NC}"
AVAILABLE_SPACE=$(df -BG "$PROJECT_ROOT" | tail -1 | awk '{print $4}' | sed 's/G//')
REQUIRED_SPACE=350  # GB

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo -e "${YELLOW}Warning: Low disk space detected${NC}"
    echo "  Available: ${AVAILABLE_SPACE}GB"
    echo "  Recommended: ${REQUIRED_SPACE}GB+"
    echo "  Mainnet node will require ~250GB, Preprod ~75GB"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
else
    echo -e "${GREEN}✓ Sufficient disk space available (${AVAILABLE_SPACE}GB)${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Setup completed successfully!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review configuration files in config/mainnet/ and config/preprod/"
echo "  2. Adjust .env.mainnet and .env.preprod if needed"
echo "  3. Run './scripts/start.sh' to start both nodes"
echo "  4. Monitor with './scripts/logs.sh'"
echo ""

