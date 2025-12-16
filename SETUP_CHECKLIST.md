# Setup Checklist

## Files Created

- [x] `docker-compose.yml` - Docker Compose configuration for both nodes
- [x] `.env.example` - Example environment variables
- [x] `.env.mainnet` - Mainnet environment configuration
- [x] `.env.preprod` - Preprod environment configuration
- [x] `README.md` - Comprehensive documentation
- [x] `.gitignore` - Git ignore file

## Scripts Created

- [x] `scripts/setup.sh` - Initial setup script
- [x] `scripts/download-genesis.sh` - Downloads genesis files from official sources
- [x] `scripts/start.sh` - Starts both nodes
- [x] `scripts/stop.sh` - Stops both nodes
- [x] `scripts/logs.sh` - View logs helper

## Directories Created

- [x] `config/mainnet/` - Mainnet configuration (will contain downloaded files)
- [x] `config/preprod/` - Preprod configuration (will contain downloaded files)
- [x] `data/mainnet/` - Mainnet blockchain data storage
- [x] `data/preprod/` - Preprod blockchain data storage
- [x] `scripts/` - Helper scripts directory

## Next Steps

1. Run `./scripts/setup.sh` to:
   - Check prerequisites
   - Create .env file from .env.example
   - Download all genesis files
   - Validate configuration

2. Run `./scripts/start.sh` to start both nodes

3. Monitor with `./scripts/logs.sh all`

## Configuration Files

Configuration files (config.json, topology.json, genesis files) will be automatically downloaded by `scripts/download-genesis.sh` when you run `scripts/setup.sh`. These files come from official Cardano sources and will have the correct paths and structure.
