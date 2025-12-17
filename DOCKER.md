# Docker Compose Setup for Dreamink

This repository includes Docker Compose configurations that work seamlessly across **Windows**, **Mac**, and **Linux** with both **Docker** and **Podman**.

## Quick Start (One Command!)

### Development Mode (with hot-reload)
```bash
docker compose up
```
Visit http://localhost:3000

### Production/Demo Mode
```bash
docker compose -f docker-compose.prod.yml up --build
```
Visit http://localhost:3000

> [!NOTE]
> The setup is completely seamless - databases are created automatically, migrations run automatically, and everything just works.

## What You Get

### Development Mode (`docker-compose.yml`)
- Full Rails development server with debugging enabled
- PostgreSQL database (auto-created and migrated)
- Live code reloading (edit code, see changes immediately)
- Asset watchers (JavaScript and CSS auto-rebuild)
- Volume-mounted source code (your local edits sync to container)
- Cached gems and node_modules (faster restarts)

**Perfect for:** Daily development work, testing features, debugging

### Production Mode (`docker-compose.prod.yml`)
- Optimized production build (multi-stage Docker image)
- Thruster HTTP proxy for performance
- Precompiled assets
- Production-ready Puma server
- Smaller image size (no dev dependencies)

**Perfect for:** Demos, testing production builds, CI/CD pipelines

## Tested and Verified

This Docker Compose setup has been thoroughly tested on **CachyOS with Docker Compose**. During testing, we identified and fixed several issues to ensure cross-platform compatibility:

### Bugs Fixed

1. **Package Manager Mismatch** (`Dockerfile:52`)
   - **Issue:** Dockerfile expected Yarn but project uses npm
   - **Fix:** Updated to use `npm ci` with `package-lock.json`

2. **Database Password Environment Variable** (`docker-compose.prod.yml:47`)
   - **Issue:** Production config expected `DREAMINK_DATABASE_PASSWORD` but compose file passed `DATABASE_PASSWORD`
   - **Fix:** Aligned environment variable names

3. **SSL Force Redirect** (`config/environments/production.rb:32`)
   - **Issue:** Rails forced HTTPS causing `ERR_SSL_PROTOCOL_ERROR` on plain HTTP
   - **Fix:** Made SSL configurable via `RAILS_FORCE_SSL` environment variable (disabled by default for local/LAN use)

All issues have been resolved and the setup works seamlessly across platforms.

## Prerequisites

Install **one** of these:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac/Linux)
- [Podman Desktop](https://podman-desktop.io/) (alternative to Docker)

> [!TIP]
> Windows Users: Docker Desktop with WSL2 backend recommended. Both `docker compose` and `podman compose` commands work identically.

## Detailed Usage

### First-Time Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Dreamink-SNPP/dreamink-project.git
   cd dreamink-project
   ```

2. **Create environment file (IMPORTANT for Production Mode):**

   > [!IMPORTANT]
   > For production mode (`docker-compose.prod.yml`), you should create a `.env` file to ensure consistent database configuration.

   ```bash
   # Copy the example file
   cp .env.docker.example .env

   # Or create .env manually with these values:
   DATABASE_USERNAME=dreamink_user
   DATABASE_PASSWORD=dreamink_password
   DATABASE_PORT=5432
   RAILS_FORCE_SSL=false
   RAILS_ASSUME_SSL=false
   ```

   > [!NOTE]
   > Development mode (`docker-compose.yml`) works without a `.env` file, but production mode requires it to prevent database connection issues.

3. **Start the application:**
   ```bash
   # Development mode (no .env required)
   docker compose up

   # Production mode (requires .env file)
   docker compose -f docker-compose.prod.yml up --build
   ```

4. **Access the application:**
   - Open http://localhost:3000 in your browser
   - Create an account and start using Dreamink!

### Common Commands

#### Development Mode

```bash
# Start all services (Postgres + Rails + Asset watchers)
docker compose up

# Start in background (detached mode)
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Stop and remove volumes (deletes database)
docker compose down -v

# Restart a specific service
docker compose restart web

# Run Rails console
docker compose exec web bin/rails console

# Run database migrations
docker compose exec web bin/rails db:migrate

# Run tests
docker compose exec web bin/rails test
```

> [!CAUTION]
> Running `docker compose down -v` will delete all database data permanently. Use this only when you want to start with a fresh database.

#### Production Mode

```bash
# Build and start (rebuilds image if Dockerfile changed)
docker compose -f docker-compose.prod.yml up --build

# Start in background
docker compose -f docker-compose.prod.yml up -d

# View logs
docker compose -f docker-compose.prod.yml logs -f

# Stop all services
docker compose -f docker-compose.prod.yml down

# Rebuild the image from scratch
docker compose -f docker-compose.prod.yml build --no-cache

# Run Rails console (production mode)
docker compose -f docker-compose.prod.yml exec web bin/rails console
```

### Platform-Specific Notes

#### Windows

**Docker Desktop (Recommended):**
- Enable WSL2 backend in Docker Desktop settings
- Run commands in PowerShell, CMD, or WSL2 terminal
- Both `docker compose` and `docker-compose` work

**Podman Desktop:**
- Install Podman Desktop from [podman-desktop.io](https://podman-desktop.io/)
- Use `podman compose` instead of `docker compose`
- All commands are identical: `podman compose up`, `podman compose down`, etc.

> [!NOTE]
> Docker/Podman handles Windows paths automatically. Use forward slashes in commands: `docker compose -f docker-compose.prod.yml up`

**Windows-Specific Setup Steps:**

```powershell
# 1. Ensure Docker Desktop is running (check system tray for green icon)

# 2. Navigate to project directory
cd C:\Users\YourUsername\Downloads\dreamink-project

# 3. Create .env file (IMPORTANT - prevents database errors)
# PowerShell:
Copy-Item .env.docker.example .env

# Or create manually with these contents:
# DATABASE_USERNAME=dreamink_user
# DATABASE_PASSWORD=dreamink_password
# DATABASE_PORT=5432
# RAILS_FORCE_SSL=false
# RAILS_ASSUME_SSL=false

# 4. Start Docker Compose
docker compose -f docker-compose.prod.yml up --build

# 5. Access at http://localhost:3000
```

> [!WARNING]
> If you see `FATAL: database "dreamink_user" does not exist` in the logs, you forgot to create the `.env` file. Stop the containers with `Ctrl+C`, create the `.env` file, then run `docker compose -f docker-compose.prod.yml down -v` and start again.

#### macOS

**Docker Desktop:**
- Install from [docker.com](https://www.docker.com/products/docker-desktop/)
- Works out of the box with both Intel and Apple Silicon
- File sync is automatic via Docker Desktop's VM

**Podman:**
- Install via Homebrew: `brew install podman podman-compose`
- Initialize: `podman machine init && podman machine start`
- Use `podman compose` instead of `docker compose`

#### Linux

**Docker:**
```bash
# Install Docker Engine
curl -fsSL https://get.docker.com | sh

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

**Podman (rootless, more secure):**
```bash
# Install Podman
sudo apt install podman podman-compose  # Debian/Ubuntu
sudo dnf install podman podman-compose  # Fedora/RHEL

# Use podman compose instead of docker compose
podman compose up
```

## Architecture

### Services Overview

#### Development (`docker-compose.yml`)

| Service | Image | Purpose | Port |
|---------|-------|---------|------|
| postgres | postgres:16 | Database server | 5432 |
| web | ruby:3.4.6-slim | Rails app with debugging | 3000 |
| js | node:22-slim | JavaScript asset watcher | - |
| css | ruby:3.4.6-slim | Tailwind CSS watcher | - |

#### Production (`docker-compose.prod.yml`)

| Service | Image | Purpose | Port |
|---------|-------|---------|------|
| postgres | postgres:16 | Database server | 5432 |
| web | (built from Dockerfile) | Rails app with Thruster | 3000→80 |

### Data Persistence

**Development volumes:**
- `postgres_data`: Database files (persistent across restarts)
- `bundle_cache`: Ruby gems (faster startups)
- `node_modules`: NPM packages (faster startups)
- `.:/rails`: Your source code (live sync)

**Production volumes:**
- `postgres_prod_data`: Production database files

> [!WARNING]
> To reset the database, use `docker compose down -v`. This will permanently delete all data.

```bash
# Development
docker compose down -v

# Production
docker compose -f docker-compose.prod.yml down -v
```

## Troubleshooting

### Port Already in Use

**Error:** `Bind for 0.0.0.0:3000 failed: port is already allocated`

**Solution:**
```bash
# Stop any local Rails server
# Then change port in .env:
DATABASE_PORT=5433  # If 5432 is taken
# Or stop the conflicting service
```

### Permission Denied (Linux/Podman)

**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login, or run:
newgrp docker

# For Podman, run rootless:
podman compose up  # No sudo needed!
```

### Database Connection Refused

**Error:** `could not connect to server: Connection refused`

**Solution:**
```bash
# Wait for Postgres to be ready (check health)
docker compose ps

# View postgres logs
docker compose logs postgres

# Ensure DATABASE_HOST=postgres in container (not localhost)
```

### Database Does Not Exist (Production Mode)

**Error:** `FATAL: database "dreamink_user" does not exist` (in PostgreSQL logs)

**Cause:** Missing or misconfigured `.env` file for production mode.

**Solution:**

> [!IMPORTANT]
> This error occurs when running production mode without a `.env` file. The database credentials must be consistent between the PostgreSQL and Rails containers.

```bash
# 1. Stop all containers
docker compose -f docker-compose.prod.yml down -v

# 2. Create .env file from example
cp .env.docker.example .env

# 3. Verify .env contents (should have these variables)
cat .env
# DATABASE_USERNAME=dreamink_user
# DATABASE_PASSWORD=dreamink_password
# RAILS_FORCE_SSL=false
# RAILS_ASSUME_SSL=false

# 4. Start fresh (the -v flag removed old database volumes)
docker compose -f docker-compose.prod.yml up --build
```

**Why this happens:** Without a `.env` file, environment variable defaults may not be properly shared between services, causing database name mismatches.

### Slow Startup (First Time)

> [!NOTE]
> First startup takes 2-5 minutes because Docker needs to:
> - Download images (Ruby, Node, Postgres)
> - Install all gems (`bundle install`)
> - Install all npm packages
> - Run database migrations
>
> Subsequent startups take only 10-30 seconds (gems/packages cached)

### Changes Not Reflecting (Development)

**Problem:** Code changes not showing up

**Solutions:**
```bash
# 1. Check if volume is mounted
docker compose exec web ls -la /rails

# 2. Restart the web service
docker compose restart web

# 3. Check asset watchers are running
docker compose logs js
docker compose logs css

# 4. Hard reset
docker compose down
docker compose up
```

### Production Build Fails

**Error:** Build failures during `docker compose -f docker-compose.prod.yml up --build`

**Solutions:**
```bash
# 1. Clean build (no cache)
docker compose -f docker-compose.prod.yml build --no-cache

# 2. Check for .env issues (SECRET_KEY_BASE)
# Production generates one automatically, but you can set:
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> .env

# 3. Verify Dockerfile syntax
docker build -t dreamink-test .
```

## Differences from Local Development

### What's the Same
- Same Ruby version (3.4.6)
- Same Node version (22.19.0)
- Same PostgreSQL version (16)
- Same source code
- Same Rails commands work

### What's Different
- **No need for `bin/dev`**: Docker Compose runs all processes
- **No need for `rbenv`**: Ruby is in the container
- **No need for local PostgreSQL**: Runs in container
- **No need for `bundle install`**: Happens automatically
- **No need for `npm install`**: Happens automatically

## Advanced Usage

### Running Specific Services

```bash
# Only run database (use local Rails)
docker compose up postgres

# Only run Rails (if you have db elsewhere)
docker compose up web
```

### Executing Commands in Containers

```bash
# Rails console
docker compose exec web bin/rails console

# Database console
docker compose exec web bin/rails dbconsole

# Bash shell
docker compose exec web bash

# Run migrations
docker compose exec web bin/rails db:migrate

# Run seeds
docker compose exec web bin/rails db:seed

# Run tests
docker compose exec web bin/rails test

# Generate scaffolding
docker compose exec web bin/rails generate scaffold Post title:string
```

### Using with CI/CD

**GitHub Actions Example:**
```yaml
- name: Run tests in Docker
  run: |
    docker compose -f docker-compose.prod.yml up -d
    docker compose -f docker-compose.prod.yml exec -T web bin/rails test
```

**GitLab CI Example:**
```yaml
test:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker compose -f docker-compose.prod.yml up -d
    - docker compose -f docker-compose.prod.yml exec -T web bin/rails test
```

## FAQ

### Why does this use HTTP instead of HTTPS?

> [!NOTE]
> The production Docker Compose setup (`docker-compose.prod.yml`) is configured for **HTTP (not HTTPS)** by default. This is intentional and appropriate for Dreamink's primary use case: running on local computers and trusted LANs.

**Security through deployment model:**
- **Localhost (127.0.0.1):** Traffic never leaves your computer - fully secure
- **LAN (192.168.x.x, 10.x.x.x):** Confined to your trusted local network
- **Dreamink's purpose:** Creative tool for screenplay organization, not handling payment/medical data

**When you DO need HTTPS:**
- Deploying to the public internet with a domain name
- Handling sensitive user data beyond creative content
- Compliance requirements

For public internet deployment with SSL, use Kamal (already configured) with Let's Encrypt, or set up SSL certificates manually and configure:
```bash
# In your .env or docker-compose override
RAILS_FORCE_SSL=true
RAILS_ASSUME_SSL=true
```

### Can I use this in production?

> [!IMPORTANT]
> The `docker-compose.prod.yml` file builds a production-ready image suitable for:
> - **Local/LAN deployment:** Ready to use as-is
> - **Public internet deployment:** Add SSL certificates and update SSL settings
>
> For large-scale public deployments, consider:
> - Using Kamal (already configured in this project)
> - Kubernetes for orchestration
> - Managed databases (AWS RDS, Google Cloud SQL, etc.)
> - CDN for static assets

### Does this work with Podman Compose?

Yes! 100% compatible. Just use `podman compose` instead of `docker compose`:
```bash
podman compose up
podman compose -f docker-compose.prod.yml up --build
```

### Can I switch between local and Docker development?

Yes! They can coexist:
```bash
# Stop Docker services
docker compose down

# Run locally
bin/dev

# Switch back to Docker
docker compose up
```

> [!TIP]
> Use `DATABASE_HOST=localhost` in `.env` for local development. Docker Compose will automatically override it to `postgres` for containers.

### How do I update dependencies?

**Development mode:**
```bash
# Update Gemfile or package.json locally
# Then restart containers (gems/packages auto-install)
docker compose down
docker compose up
```

**Production mode:**
```bash
# Update Gemfile or package.json
# Rebuild the image
docker compose -f docker-compose.prod.yml up --build
```

### How much disk space does this use?

**First time:**
- Docker images: ~1.5 GB
- Volumes (gems, node_modules, DB): ~500 MB
- **Total: ~2 GB**

**After development:**
- Database grows with data
- Logs in `tmp/` directory

To reclaim space:
```bash
# Remove all stopped containers, unused networks, and dangling images
docker system prune

# Remove everything including volumes (deletes databases)
docker system prune -a --volumes
```

> [!CAUTION]
> Running `docker system prune -a --volumes` will delete all Docker data including databases. Only use this if you're sure you want to remove everything.

## Support

- **GitHub Issues**: [Report bugs](https://github.com/Dreamink-SNPP/dreamink-project/issues)
- **Documentation**: See main [README.md](README.md) and [CLAUDE.md](CLAUDE.md)
- **Docker Docs**: [docs.docker.com](https://docs.docker.com/)
- **Podman Docs**: [podman.io](https://podman.io/)

---

**Enjoy seamless development with Dreamink!**
