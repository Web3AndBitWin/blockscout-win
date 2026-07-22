# AESC Lightweight Blockscout Docker Design

## Goal

Run a lightweight Blockscout deployment for the local AESC development chain and expose the explorer at `http://localhost`.

## Architecture

Reuse `docker-compose/no-services.yml` for PostgreSQL, Redis, Blockscout backend, frontend, and Nginx. Add `docker-compose/aesc-local.yml` as a Compose override so AESC-specific settings remain isolated from upstream Blockscout defaults.

The backend connects from Docker to the host-published AESC RPC endpoints:

- HTTP and trace RPC: `http://host.docker.internal:8545`
- WebSocket RPC: `ws://host.docker.internal:8546`
- EVM chain ID: `71602`

The frontend displays the network as AESC Devnet with AEX as the native 18-decimal currency.

## Components

- PostgreSQL stores indexed chain data.
- Redis supports caching and background work.
- Blockscout backend indexes blocks and serves APIs.
- Blockscout frontend serves the explorer UI.
- Nginx exposes the combined application on host port 80.

Stats, Visualizer, Sig Provider, User Ops Indexer, and NFT Media Handler are outside this deployment scope.

## Data Flow

The AESC node publishes EVM RPC ports 8545 and 8546 on the host. The Blockscout backend reaches those endpoints through `host.docker.internal`, indexes blocks into PostgreSQL, and serves data to the frontend through Nginx.

## Error Handling

Deployment must stop for configuration errors, occupied host port 80, an unreachable AESC RPC endpoint, failed database migrations, or an unhealthy backend. Diagnostics use resolved Compose configuration, container status, and focused service logs before any corrective change.

## Verification

1. Validate the merged Compose configuration.
2. Confirm the AESC node returns EVM chain ID `0x117b2`.
3. Start the lightweight Compose stack.
4. Confirm required containers are running and the backend has completed migrations.
5. Confirm Blockscout APIs respond through `http://localhost`.
6. Confirm indexed block height is nonzero and advances toward the AESC node height.

## Non-Goals

- Production hardening, TLS, public DNS, backups, and external database hosting.
- Modifying AESC node behavior.
- Enabling optional Blockscout microservices.
