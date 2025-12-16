# Dolos Homelab Docker Setup

A production-ready Docker Compose setup for running two Cardano Dolos nodes (mainnet and preprod) on a homelab server.

## Overview

This setup provides:
- **Mainnet Node**: Full Cardano mainnet node
- **Preprod Node**: Pre-production testnet node
- Automatic genesis file download from official sources
- Persistent data storage
- Easy management scripts
- Health monitoring
- Automatic restart on failure

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: V2 plugin (install: `sudo apt-get install docker-compose-plugin`)
- **Disk Space**: Minimum 350GB, recommended 500GB+
  - Mainnet: ~250GB
  - Preprod: ~75GB
  - OS and overhead: ~50GB
  - Growth buffer: ~50GB
- **RAM**: Minimum 8GB, recommended 16GB+
- **Network**: Stable internet connection for initial sync

## Quick Start

1. **Clone and Setup**:
   ```bash
   cd dolosHomelab
   ./scripts/setup.sh
   ```

2. **Start Nodes**:
   ```bash
   ./scripts/start.sh
   ```

3. **View Logs**:
   ```bash
   ./scripts/logs.sh all
   ```

4. **Stop Nodes**:
   ```bash
   ./scripts/stop.sh
   ```

## Directory Structure

```
dolosHomelab/
├── docker-compose.yml          # Docker Compose configuration
├── .env.example                # Example environment variables
├── .env.mainnet                # Mainnet environment config
├── .env.preprod                # Preprod environment config
├── config/
│   ├── mainnet/                # Mainnet configuration files
│   │   ├── config.json         # Node configuration
│   │   ├── topology.json       # Peer topology
│   │   ├── byron-genesis.json  # Byron era genesis
│   │   ├── shelley-genesis.json # Shelley era genesis
│   │   ├── alonzo-genesis.json # Alonzo era genesis
│   │   └── conway-genesis.json # Conway era genesis
│   └── preprod/                # Preprod configuration files
│       └── (same structure)
├── data/
│   ├── mainnet/                # Mainnet blockchain data
│   └── preprod/                # Preprod blockchain data
├── scripts/
│   ├── setup.sh                # Initial setup script
│   ├── download-genesis.sh     # Download genesis files
│   ├── start.sh                # Start nodes
│   ├── stop.sh                 # Stop nodes
│   └── logs.sh                 # View logs
└── README.md                   # This file
```

## Port Mappings

### Mainnet Node
- **API Port**: 3001 (Cardano node communication)
- **Web UI Port**: 8080 (if applicable)

### Preprod Node
- **API Port**: 3002 (Cardano node communication)
- **Web UI Port**: 8081 (if applicable)

**Note**: Adjust ports in `.env.mainnet` and `.env.preprod` if conflicts occur.

## Configuration

### Environment Variables

Docker Compose uses environment variables from a `.env` file (created from `.env.example`) or system environment. The `.env.mainnet` and `.env.preprod` files are provided as reference examples.

**Important**: Docker Compose automatically loads a `.env` file from the project root. To use custom settings:

1. Copy the example: `cp .env.example .env`
2. Edit `.env` with your settings
3. Or set environment variables before running `docker compose`

Example `.env` customization:

```bash
# Docker image
CARDANO_NODE_IMAGE=inputoutput/cardano-node:latest

# Ports
MAINNET_PORT=3001
MAINNET_WEB_PORT=8080

# Memory limits
MAINNET_MEMORY_LIMIT=4G
MAINNET_MEMORY_RESERVATION=2G
```

### Genesis Files

Genesis files are automatically downloaded from official Cardano sources:
- **Mainnet**: https://book.world.dev.cardano.org/environments/mainnet/
- **Preprod**: https://book.world.dev.cardano.org/environments/preprod/

The setup script downloads:
- `config.json` - Node configuration
- `topology.json` - Peer connections
- `byron-genesis.json` - Byron era parameters
- `shelley-genesis.json` - Shelley era parameters
- `alonzo-genesis.json` - Alonzo era parameters
- `conway-genesis.json` - Conway era parameters

## Usage

### Initial Setup

Run the setup script to:
1. Check prerequisites
2. Create directory structure
3. Download genesis files
4. Validate configuration

```bash
./scripts/setup.sh
```

### Starting Nodes

Start both nodes:
```bash
./scripts/start.sh
```

Or start individually with Docker Compose:
```bash
docker compose up -d dolos-mainnet
docker compose up -d dolos-preprod
```

### Viewing Logs

View logs from a specific node:
```bash
./scripts/logs.sh mainnet
./scripts/logs.sh preprod
./scripts/logs.sh all
```

Follow logs in real-time:
```bash
./scripts/logs.sh mainnet -f
./scripts/logs.sh all -f
```

Show last N lines:
```bash
./scripts/logs.sh mainnet -n 200
```

### Stopping Nodes

Stop both nodes gracefully:
```bash
./scripts/stop.sh
```

Or stop individually:
```bash
docker compose stop dolos-mainnet
docker compose stop dolos-preprod
```

### Checking Status

Check container status:
```bash
docker compose ps
```

Check individual container:
```bash
docker ps | grep dolos-mainnet
docker ps | grep dolos-preprod
```

### Accessing Node Socket

The node socket is available at:
- Mainnet: `/var/lib/docker/volumes/doloshomelab_dolos-mainnet-ipc/_data/node.socket`
- Preprod: `/var/lib/docker/volumes/doloshomelab_dolos-preprod-ipc/_data/node.socket`

Or access from within container:
```bash
docker exec dolos-mainnet ls -la /ipc/
```

## Monitoring

### Disk Space

Monitor disk usage:
```bash
du -sh data/mainnet
du -sh data/preprod
df -h
```

### Container Resources

View resource usage:
```bash
docker stats dolos-mainnet dolos-preprod
```

### Health Checks

Docker Compose includes health checks that verify the node socket exists:
```bash
docker inspect dolos-mainnet | grep -A 10 Health
```

## Troubleshooting

### Node Won't Start

1. **Check logs**:
   ```bash
   ./scripts/logs.sh mainnet
   ```

2. **Verify genesis files exist**:
   ```bash
   ls -la config/mainnet/
   ```

3. **Check disk space**:
   ```bash
   df -h
   ```

4. **Verify Docker is running**:
   ```bash
   docker info
   ```

### Genesis Files Missing

Re-download genesis files:
```bash
./scripts/download-genesis.sh
```

### Port Conflicts

Edit `.env` file to change ports:
```bash
MAINNET_PORT=3001  # Change to available port
```

Then restart:
```bash
docker compose down
./scripts/start.sh
```

### Container Keeps Restarting

Check logs for errors:
```bash
./scripts/logs.sh mainnet -n 500
```

Common issues:
- Insufficient disk space
- Missing genesis files
- Port already in use
- Memory limit too low

### Slow Synchronization

Initial sync can take days. Factors affecting speed:
- Network bandwidth
- Disk I/O performance (SSD recommended)
- System resources (CPU/RAM)

Monitor progress:
```bash
./scripts/logs.sh mainnet -f | grep -i "chain\|slot\|block"
```

### Data Directory Permissions

If permission errors occur:
```bash
sudo chown -R $USER:$USER data/
chmod -R 755 data/
```

## Maintenance

### Updating Docker Image

Pull latest image:
```bash
docker compose pull
docker compose up -d
```

### Cleaning Up

Stop and remove containers (keeps data):
```bash
docker compose down
```

Stop and remove containers and volumes (deletes data):
```bash
docker compose down -v
```

**Warning**: Removing volumes deletes all blockchain data!

### Log Rotation

Docker manages log rotation. Configure in `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## Resource Requirements

### Minimum
- **CPU**: 2 cores
- **RAM**: 8GB
- **Disk**: 350GB SSD
- **Network**: 10 Mbps

### Recommended
- **CPU**: 4+ cores
- **RAM**: 16GB+
- **Disk**: 500GB+ NVMe SSD
- **Network**: 100+ Mbps

### Disk Space Breakdown
- Mainnet database: ~250GB (grows ~1-2GB/month)
- Preprod database: ~75GB
- OS and Docker: ~30GB
- Logs and overhead: ~20GB
- Growth buffer: ~50GB

## Security Considerations

1. **Firewall**: Configure firewall rules for exposed ports
2. **Network**: Consider running nodes on internal network only
3. **Updates**: Keep Docker and images updated
4. **Backups**: Regular backups of data directories (if needed)

## Support and Documentation

- **Cardano Node Docs**: https://developers.cardano.org/
- **Docker Compose Docs**: https://docs.docker.com/compose/
- **Cardano Node Repository**: https://github.com/input-output-hk/cardano-node

## License

This setup configuration is provided as-is for homelab use.

## Contributing

Improvements and suggestions are welcome! Please ensure:
- Scripts work on common Linux distributions
- Documentation is updated
- Changes are tested

## Changelog

### Version 1.0.0
- Initial release
- Support for mainnet and preprod nodes
- Automatic genesis file download
- Management scripts
- Health checks and monitoring

