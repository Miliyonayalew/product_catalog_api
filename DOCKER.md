# Docker Development Setup

This Rails API can be run using Docker Compose for a consistent development environment. The default setup uses SQLite for simplicity.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# Run the setup script
./bin/docker-setup

# Start the application
docker-compose up
```

### Option 2: Manual Setup

```bash
# Build and start the web service
docker-compose up -d --build web

# Setup the database (SQLite)
docker-compose run --rm web rails db:prepare db:seed

# Tail logs
docker-compose logs -f web
```

## Services

The Docker Compose setup includes:

- **web**: Rails API server (port 3000)

## Common Commands

```bash
# Start the web service
docker-compose up web

# Start in background
docker-compose up -d web

# Stop all services
docker-compose down

# View logs
docker-compose logs web
docker-compose logs -f web  # Follow logs

# Run Rails commands
docker-compose run --rm web rails console
docker-compose run --rm web rails db:migrate
docker-compose run --rm web rails db:seed

# Run tests
docker-compose run --rm web rails test

# Access the web container shell
docker-compose exec web bash

# Rebuild containers (after Gemfile changes)
docker-compose build web
docker-compose up --build web
```

## Environment Variables

Key environment variables (configured in docker-compose.yml):

- `RAILS_ENV=development`

## Database

The setup uses SQLite in development. The database file is persisted in the `storage/` directory mounted into the container.

## Troubleshooting

### Database issues (SQLite)
```bash
# Recreate the database
docker-compose run --rm web bash -lc "rm -f storage/development.sqlite3 && rails db:prepare"
```

### Permission issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Clean slate
```bash
# Remove all containers and volumes
docker-compose down -v
docker-compose build --no-cache
```

## Development Workflow

1. Make code changes (files are mounted as volumes)
2. The Rails server will automatically reload
3. Database changes require running migrations:
   ```bash
   docker-compose run --rm web rails db:migrate
   ```

## Accessing Services

- **Rails API**: http://localhost:3000
  (SQLite file at `storage/development.sqlite3`)

## Production Notes

This setup is optimized for development. For production:
- Use the existing `Dockerfile` (production-ready)
- Set proper environment variables
- Use managed database services
- Configure proper secrets management