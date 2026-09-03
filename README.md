# Homelab Docker

A collection of Docker Compose configurations for running a personal homelab infrastructure. This repository contains containerized services for media management, file sharing, web hosting, and more.

## 🎯 Overview

This homelab setup provides:
- **Photo Management** - Immich for autonomous photo management and storage
- **Media Streaming** - Jellyfin and Plex for organizing and streaming your media library
- **Web Services** - WordPress for blogging and web hosting
- **File Sharing** - Samba for network file shares
- **Reverse Proxy** - Nginx for routing and SSL termination

## 📦 Services

### Immich
Photo and video management platform with powerful search and organization capabilities.
- **Port**: 2283
- **Location**: `immich/`
- **Features**: AI-powered search, timeline view, sharing capabilities
- **Storage**: Media stored in configurable location via `UPLOAD_LOCATION` environment variable

### Jellyfin
Open-source media server for streaming movies, TV shows, music, and photos.
- **Port**: 8096
- **Location**: `jellyfin/`
- **Features**: Responsive UI, transcoding, multi-user support
- **Configuration**: `/data/jellyfin/config`
- **Media Location**: `/mnt/bigshare/media`

### Plex
Plex media server for personal media streaming (optional alternative to Jellyfin).
- **Network**: Host mode
- **Location**: `plex/`
- **Timezone**: America/New_York
- **Configuration**: Requires `PLEX_CLAIM` token for initial setup

### WordPress
Full-featured WordPress site with MySQL database backend.
- **Domain**: blog.juissy.net
- **Location**: `wordpress/`
- **Database**: MySQL 8.0
- **Requires**: `.env` file with `MYSQL_WP_PASS`

### Nginx
Reverse proxy for routing traffic and SSL/TLS termination.
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Location**: `nginx/`
- **Configuration**: `nginx.conf`
- **SSL Certificates**: Mounted from `./certs/`

### Samba
Network file sharing service for Windows, Mac, and Linux clients.
- **Ports**: 139, 445
- **Location**: `samba/`
- **Share**: `/zips` from immich exports
- **Users**: justin, krissy

## 📋 Prerequisites

- Docker and Docker Compose installed
- Linux or Windows with Docker Desktop/WSL2
- Sufficient disk space for media libraries
- Network connectivity between services
- Environment files (`.env`) configured for each service that requires it

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/pogipants/homelab-docker.git
   cd homelab-docker
   ```

2. **Set up environment files** (where needed)
   Each service that requires environment variables needs a `.env` file:
   - `wordpress/.env` - Set `MYSQL_WP_PASS`
   - `immich/.env` - Configure `UPLOAD_LOCATION`, `IMMICH_VERSION`, etc.

3. **Create Docker network** (for services that use the immich network)
   ```bash
   docker network create immich
   ```

4. **Start services**
   ```bash
   # Start a specific service
   cd <service-name>
   docker-compose up -d

   # Or start from root and launch individual services
   ```

5. **Access services**
   - Immich: http://localhost:2283
   - Jellyfin: http://localhost:8096
   - WordPress: https://blog.juissy.net (or configured domain)

## 🗂️ Directory Structure

```
homelab-docker/
├── README.md
├── immich/              # Photo management service
│   └── docker-compose.yml
├── jellyfin/            # Media server
│   ├── docker-compose.yml
│   └── docker-compose-jellyfin.service
├── nginx/               # Reverse proxy
│   ├── docker-compose.yml
│   ├── nginx.conf
│   └── certs/          # SSL certificates (not in repo)
├── plex/                # Alternative media server
│   └── docker-compose.yml
├── samba/               # Network file sharing
│   └── docker-compose.yml
└── wordpress/           # Website/blog
    └── docker-compose.yml
```

## ⚙️ Configuration Details

### Storage Paths
The configuration uses several persistent storage locations:
- `/data/immich/` - Immich uploads and data
- `/data/jellyfin/` - Jellyfin configuration and cache
- `/mnt/bigshare/` - Media library and shared storage
- `./config/` - Service-specific configuration (relative to service directory)

### Networking
- **immich network**: Used by Immich, Nginx, and related services
- **proxy network**: Used by WordPress and its database
- **host network**: Used by Plex service

### Environment Variables
Critical environment variables needed:
- `IMMICH_VERSION` - Docker image version for Immich
- `UPLOAD_LOCATION` - Path for Immich media storage
- `MYSQL_WP_PASS` - MySQL password for WordPress
- `PLEX_CLAIM` - Plex claim token (found at https://www.plex.tv/claim)

## 📝 Usage Tips

### Immich
- Versions are managed via environment variables to prevent incompatibilities
- Hardware acceleration can be enabled for ML and transcoding (see commented hwaccel sections)
- Backup the `.env` file and custom configuration paths

### Jellyfin
- User ID 1000:1000 is used to ensure proper file permissions
- Subtitle burn-in fonts can be added (see commented section)
- Supports multiple media locations for organization

### WordPress
- Database password must be set in `.env` file before first run
- Uses Let's Encrypt for SSL (requires proper DNS setup and email)
- Virtual host configuration supports multiple domains

### Samba
- Users `justin` and `krissy` are configured
- `/zips` directory shares Immich exports for easy download
- Read-only and read-write shares can be configured per user

## 🔒 Security Notes

- Store `.env` files securely and never commit them to version control
- Use strong passwords for WordPress and Samba
- Keep SSL certificates updated (Let's Encrypt can automate this)
- Restrict network access to services that don't need public exposure
- Use Nginx as a reverse proxy for external access

## 🆘 Troubleshooting

**Immich not connecting to Redis/Database**: Ensure the immich network is created and services are on the same network

**Jellyfin: Permission denied errors**: Check that media directories are accessible by user 1000:1000

**WordPress database errors**: Verify `MYSQL_WP_PASS` is set in `.env` and database container is running

**Plex not starting**: Set the `PLEX_CLAIM` token from https://www.plex.tv/claim

**Nginx routing issues**: Verify `nginx.conf` is properly configured for each backend service

## 📚 Additional Resources

- [Immich Documentation](https://immich.app/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Plex Documentation](https://support.plex.tv/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

This is a personal homelab project. Feel free to fork and adapt for your own use!

## 📄 License

This repository configuration is provided as-is for personal use.