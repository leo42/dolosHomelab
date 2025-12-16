# Dolos Homelab Docker Setup

A production-ready Docker Compose setup for running Dolos nodes (mainnet and preprod) on a homelab server.

## Overview

This setup provides:
- **Mainnet Node**: Dolos node for Cardano mainnet
- **Preprod Node**: Dolos node for preprod testnet
- Mithril snapshot bootstrap for fast synchronization
- Persistent data storage
- Health monitoring
- Automatic restart on failure

## What is Dolos?

Dolos is a lightweight Cardano data node that provides efficient blockchain data access through multiple APIs (gRPC, Mini Blockfrost, Ouroboros). It uses Mithril snapshots for fast bootstrapping instead of syncing from genesis.

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: V2 plugin (install: `sudo apt-get install docker-compose-plugin`)
- **Disk Space**: Minimum 200GB, recommended 300GB+
  - Mainnet: ~150GB
  - Preprod: ~50GB
  - OS and overhead: ~50GB
- **RAM**: Minimum 4GB, recommended 8GB+
- **Network**: Stable internet connection for initial bootstrap

## Quick Start

1. **Bootstrap the nodes** (one-time operation):
   ```bash
   # Bootstrap mainnet
   docker compose run --rm dolos-mainnet bootstrap
   
   # Bootstrap preprod
   docker compose run --rm dolos-preprod bootstrap
   ```

2. **Start the nodes**:
   ```bash
   docker compose up -d
   ```

3. **View logs**:
   ```bash
   docker compose logs -f
   ```

4. **Stop the nodes**:
   ```bash
   docker compose down
   ```

## Directory Structure

```
dolosHomelab/
├── docker-compose.yml          # Docker Compose configuration
├── .env                        # Environment variables (optional)
├── .gitignore
├── README.md                   # This file
├── config/
│   ├── mainnet/
│   │   └── daemon.toml         # Dolos configuration for mainnet
│   └── preprod/
│       └── daemon.toml         # Dolos configuration for preprod
└── data/
    ├── mainnet/                # Mainnet blockchain data
    └── preprod/               # Preprod blockchain data
```

## Port Mappings

### Mainnet Node
- **gRPC API**: 50051
- **Mini Blockfrost API**: 3000
- **Relay**: 30031

### Preprod Node
- **gRPC API**: 50052
- **Mini Blockfrost API**: 3001
- **Relay**: 30032

**Note**: Adjust ports in `.env` file if conflicts occur.

## Configuration

### Environment Variables

Create a `.env` file in the project root to customize settings:

```bash
# Docker image (use specific version for production)
DOLOS_IMAGE=ghcr.io/txpipe/dolos:latest

# Mainnet ports
MAINNET_GRPC_PORT=50051
MAINNET_HTTP_PORT=3000
MAINNET_RELAY_PORT=30031

# Preprod ports
PREPROD_GRPC_PORT=50052
PREPROD_HTTP_PORT=3001
PREPROD_RELAY_PORT=30032

# Memory limits
MAINNET_MEMORY_LIMIT=4G
MAINNET_MEMORY_RESERVATION=2G
PREPROD_MEMORY_LIMIT=2G
PREPROD_MEMORY_RESERVATION=1G
```

### Configuration Files

Dolos uses TOML configuration files located in `config/mainnet/daemon.toml` and `config/preprod/daemon.toml`.

Key configuration sections:
- `[source]`: Mithril aggregator URL for snapshot bootstrapping
- `[storage]`: Data directory path
- `[network]`: Network magic number
- `[serve.*]`: API endpoint configurations
- `[relay]`: Relay server configuration

For detailed configuration options, see the [Dolos Configuration Schema](https://docs.txpipe.io/dolos/configuration/schema).

## Usage

### Initial Bootstrap

Before starting the daemon, you need to bootstrap the blockchain data using Mithril snapshots:

```bash
# Bootstrap mainnet (downloads and verifies snapshot)
docker compose run --rm dolos-mainnet bootstrap

# Bootstrap preprod
docker compose run --rm dolos-preprod bootstrap
```

This is a one-time operation per network. The bootstrap process downloads a verified snapshot of the blockchain, which is much faster than syncing from genesis.

### Starting Nodes

Start both nodes:
```bash
docker compose up -d
```

Start a specific node:
```bash
docker compose up -d dolos-mainnet
docker compose up -d dolos-preprod
```

### Viewing Logs

View logs from all services:
```bash
docker compose logs -f
```

View logs from a specific service:
```bash
docker compose logs -f dolos-mainnet
docker compose logs -f dolos-preprod
```

Show last N lines:
```bash
docker compose logs --tail=200 dolos-mainnet
```

### Stopping Nodes

Stop all nodes:
```bash
docker compose down
```

Stop a specific node:
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

### Accessing APIs

Once Dolos is running, you can access the APIs:

**Mini Blockfrost API** (HTTP):
```bash
curl http://localhost:3000/health  # Mainnet
curl http://localhost:3001/health  # Preprod
```

**gRPC API**:
```bash
grpcurl -plaintext localhost:50051 list  # Mainnet
grpcurl -plaintext localhost:50052 list  # Preprod
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

Docker Compose includes health checks that verify the HTTP API is responding:
```bash
docker inspect dolos-mainnet | grep -A 10 Health
```

## Troubleshooting

### Node Won't Start

1. **Check logs**:
   ```bash
   docker compose logs dolos-mainnet
   ```

2. **Verify configuration files exist**:
   ```bash
   ls -la config/mainnet/daemon.toml
   ls -la config/preprod/daemon.toml
   ```

3. **Check disk space**:
   ```bash
   df -h
   ```

4. **Verify Docker is running**:
   ```bash
   docker info
   ```

### Bootstrap Fails

If bootstrap fails:
1. Check your internet connection
2. Verify the Mithril aggregator URL is accessible
3. Ensure sufficient disk space
4. Check logs for specific error messages:
   ```bash
   docker compose run --rm dolos-mainnet bootstrap
   ```

### Port Conflicts

Edit `.env` file to change ports:
```bash
MAINNET_HTTP_PORT=3000  # Change to available port
```

Then restart:
```bash
docker compose down
docker compose up -d
```

### Container Keeps Restarting

Check logs for errors:
```bash
docker compose logs --tail=500 dolos-mainnet
```

Common issues:
- Insufficient disk space
- Configuration file errors
- Port already in use
- Memory limit too low

### Slow Synchronization

After bootstrap, Dolos should be ready quickly. If you notice slow performance:
- Check network bandwidth
- Verify disk I/O performance (SSD recommended)
- Monitor system resources (CPU/RAM)

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

For production, use a specific version tag:
```bash
DOLOS_IMAGE=ghcr.io/txpipe/dolos:v0.8.0
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
- **RAM**: 4GB
- **Disk**: 200GB SSD
- **Network**: 10 Mbps

### Recommended
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Disk**: 300GB+ NVMe SSD
- **Network**: 100+ Mbps

### Disk Space Breakdown
- Mainnet database: ~150GB (grows over time)
- Preprod database: ~50GB
- OS and Docker: ~30GB
- Logs and overhead: ~20GB

## Security Considerations

1. **Firewall**: Configure firewall rules for exposed ports
2. **Network**: Consider running nodes on internal network only
3. **Updates**: Keep Docker and images updated
4. **Backups**: Regular backups of data directories (if needed)

## Support and Documentation

- **Dolos Documentation**: https://docs.txpipe.io/dolos/
- **Docker Compose Docs**: https://docs.docker.com/compose/
- **TxPipe GitHub**: https://github.com/txpipe

## License

This setup configuration is provided as-is for homelab use.

## Contributing

Improvements and suggestions are welcome! Please ensure:
- Configuration follows Dolos best practices
- Documentation is updated
- Changes are tested

## Changelog

### Version 2.0.0
- Complete rework to use Dolos instead of Cardano node
- Removed all scripts, using Docker Compose directly
- Added Mithril snapshot bootstrap support
- Updated configuration to use TOML files
- Simplified setup process
