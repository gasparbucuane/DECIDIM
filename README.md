# decidim-app

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the open-source repository for decidim-mozambique, based on [Decidim](https://github.com/decidim/decidim).

[![Test](https://github.com/gasparbucuane/DECIDIM/actions/workflows/test.yml/badge.svg)](https://github.com/gasparbucuane/DECIDIM/actions/workflows/test.yml)

This is the instance for Decidim mozambique https://to-be-defined

## Server configuration

Docker & Docker Compose is needed, then clone this repository:

```
git clone https://github.com/gasparbucuane/DECIDIM decidim-production
```

or update:
```
cd decidim-production
git pull
```

Ensure the `.env` file has these values defined:

```bash
POSTGRES_USER=XXXXXX
POSTGRES_PASSWORD=XXXXXX
POSTGRES_DB=XXXXXX
SECRET_KEY_BASE=XXXXXX
MAPS_API_KEY=XXXXXX
EMAIL=XXXXXX
SMTP_USERNAME=XXXXXX
SMTP_PASSWORD=XXXXXX
SMTP_ADDRESS=XXXXXX
SMTP_DOMAIN=XXXXXX
SMTP_PORT=XXXXXX
DECIDIM_ENV=production
DECIDIM_HOST=decidim.example.org
DASHBOARD_AUTH_PASSWORD='$2y$10$0Ipw2g9Utl.ZgI1ozWB2aeuwiXJ1tQC3eBo/g5.MZ0GhP7iliooia' # admin
```

### SSL configuration

This application uses Traefik to handle the certificates with Let's Encrypt.
You need to ensure that the env var `DECIDIM_HOST` is set to a valid hostname pointing to the server's ip.

### Traefik Dashboard

Traefik dashboard is available at `https://DECIDIM_HOST:4430` with basic authentication enabled.

User: `admin`
Password: Generate a password into the env `DASHBOARD_AUTH_PASSWORD` with the comman `htpasswd -nBC 10 admin`

## Deploy

### Pull from Github Repository

This instance uses Docker Compose to deploy the application into the port 80 and 443 using Traefik as a web proxy.

> **Apply these instructions if the repository is in an organization**
> First, you need to make sure you are logged into the Github Docker registry (ghcr.io).
>
> 1. Go to your personal Github account, into tokens settings https://github.com/settings/tokens
> 2. Generate a new token (Classic)
> 3. Ensure you check the permission "read:packages" and "No expiration".
> 4. In the server, login into docker, introduce your username and the token generated:
>   ```bash
>   docker login ghcr.io --username github-username
>   ```
> 5. You should stay logged permanently, you should not need to repeat this process.

To re-deploy the image this should suffice:

```bash
cd decidim-production
git pull
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose-production.yml up -d
```

### Locally building the Docker image

This instance uses Docker Compose to deploy the application with Traefik as a proxy.

> If you want to locally build the docker image, change the line `image: ghcr.io/gasparbucuane/DECIDIM:${GIT_REF:-main}` for `image: decidim_${DECIDIM_ENV:-production}` first!

You need to build and tag the image:

1. Ensure you have the ENV value `DECIDIM_ENV=staging` or `DECIDIM_ENV=production`
2. Run:
   `./build.sh`
3. Deploy infrastructure and the environment:
   ```bash
   docker compose -f docker-compose.yml up -d
   docker compose -f docker-compose-production.yml up -d
   ```

## Managing Multiple Environments

This repository supports independent deployment of infrastructure and multiple Decidim environments (production and staging). Each environment can be deployed, updated, and restarted independently.

### Prerequisites

Create the required Docker networks (only needed once):

```bash
docker network create web
docker network create backend
```

### Infrastructure Deployment

Deploy the shared infrastructure (Traefik, PostgreSQL, Redis, and database backups):

```bash
docker compose -f docker-compose.yml up -d
```

This needs to be running before deploying any Decidim environment.

### Database Initialization

Before deploying any environment for the first time, you need to create PostgreSQL users, databases, and run migrations. This allows each environment to have isolated credentials.

#### Step 1: Create PostgreSQL Users and Databases

Connect to the PostgreSQL container:

```bash
docker compose -f docker-compose.yml exec db psql -U postgres
```

Then execute the following SQL commands for each environment you want to deploy:

**For Production:**

```sql
CREATE USER decidim WITH PASSWORD 'your_secure_password_here';
CREATE DATABASE decidim_prod;
ALTER DATABASE decidim_prod OWNER TO decidim;
\q
```

**For Staging:**

```sql
CREATE USER staging WITH PASSWORD 'your_staging_password_here';
CREATE DATABASE decidim_stag;
ALTER DATABASE decidim_stag OWNER TO staging;
\q
```

**For Development:**

```sql
CREATE USER decidim_dev WITH PASSWORD 'your_dev_password_here';
CREATE DATABASE decidim_dev;
ALTER DATABASE decidim_dev OWNER TO decidim_dev;
\q
```

#### Step 2: Update Environment Files

Make sure your environment files (`.env`, `.env-staging`, `.env-dev`) have the correct database credentials:

```bash
POSTGRES_USER=decidim  # or staging, decidim_dev
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=decidim_prod    # or decidim_stag, decidim_dev
```

#### Step 3: Run Rails Migrations

After creating the databases and updating credentials, run migrations for each environment:

**Production:**

```bash
docker compose -f docker-compose-production.yml run --rm decidim bundle exec rails db:migrate
docker compose -f docker-compose-production.yml run --rm decidim bundle exec rails db:seed
```

**Staging:**

```bash
docker compose -f docker-compose-staging.yml run --rm decidim-staging bundle exec rails db:migrate
docker compose -f docker-compose-staging.yml run --rm decidim-staging bundle exec rails db:seed
```

**Development:**

```bash
docker compose -f docker-compose-dev.yml run --rm decidim-dev bundle exec rails db:migrate
docker compose -f docker-compose-dev.yml run --rm decidim-dev bundle exec rails db:seed
```

### Production Environment

Deploy or update the production environment:

```bash
docker compose -f docker-compose-production.yml up -d
```

Stop the production environment:

```bash
docker compose -f docker-compose-production.yml down
```

View logs:

```bash
docker compose -f docker-compose-production.yml logs -f
```

### Staging Environment

Deploy or update the staging environment:

```bash
docker compose -f docker-compose-staging.yml up -d
```

Stop the staging environment:

```bash
docker compose -f docker-compose-staging.yml down
```

View logs:

```bash
docker compose -f docker-compose-staging.yml logs -f
```

### Development Environment

Deploy or update the development environment:

```bash
docker compose -f docker-compose-dev.yml up -d
```

Stop the development environment:

```bash
docker compose -f docker-compose-dev.yml down
```

View logs:

```bash
docker compose -f docker-compose-dev.yml logs -f
```

### Environment Configuration

Each environment requires its own configuration:

- **Production**: Uses `.env.default` and `.env` files with `DECIDIM_HOST` variable
- **Staging**: Uses `.env.default` and `.env-staging` files with `DECIDIM_STAG_HOST` variable
- **Development**: Uses `.env.default` and `.env-dev` files with `DECIDIM_DEV_HOST` variable

The `.env.default` file contains shared default values, while environment-specific files override them as needed.

Make sure to set the appropriate environment variables in each file before deploying.

### Complete Deployment Workflow

For a fresh server setup:

1. Clone the repository and configure environment files (`.env`, `.env-staging`, `.env-dev`)
2. Create Docker networks: `docker network create web && docker network create backend`
3. Deploy infrastructure: `docker compose -f docker-compose.yml up -d`
4. Initialize databases for each environment (see "Database Initialization" section above)
5. Deploy production: `docker compose -f docker-compose-production.yml up -d`
6. Deploy staging (optional): `docker compose -f docker-compose-staging.yml up -d`
7. Deploy development (optional): `docker compose -f docker-compose-dev.yml up -d`
8. Set up the application (see "Setting up the application" section below)

### Updating a Specific Environment

To update only production without affecting staging:

```bash
cd decidim-production
git pull
docker compose -f docker-compose-production.yml pull
docker compose -f docker-compose-production.yml up -d
```

The same applies for staging, development, or infrastructure updates.

### Testing Migrations with Production Data

Before applying migrations or updates to production, it's recommended to test them on the development environment using a copy of the production database. This workflow allows you to safely test changes with real data.

#### Step 1: Create a Production Database Backup

```bash
# Create a dump of the production database
docker compose -f docker-compose.yml exec db pg_dump -U decidim -d decidim_prod -F c -f /tmp/prod_backup.dump

# Copy the dump file to your host
docker compose -f docker-compose.yml cp db:/tmp/prod_backup.dump ./prod_backup.dump
```

#### Step 2: Stop Development Environment (if running)

```bash
docker compose -f docker-compose-dev.yml down
```

#### Step 3: Reset Development Database

```bash
# Drop and recreate the development database
docker compose -f docker-compose-dev.yml run --rm decidim-dev bundle exec rails db:drop db:create
```

#### Step 4: Restore Production Data to Development

```bash
# Copy the dump into the database container
docker compose -f docker-compose.yml cp ./prod_backup.dump db:/tmp/prod_backup.dump

# Restore the backup to the development database
docker compose -f docker-compose.yml exec db pg_restore -U decidim_dev -d decidim_dev -F c /tmp/prod_backup.dump

# Clean up the dump file
docker compose -f docker-compose.yml exec db rm /tmp/prod_backup.dump
rm ./prod_backup.dump
```

#### Step 5: Start Development Environment and Test Migrations

```bash
# Start the development environment
docker compose -f docker-compose-dev.yml up -d

# Run pending migrations
docker compose -f docker-compose-dev.yml exec decidim-dev bundle exec rails db:migrate

# Test your application
docker compose -f docker-compose-dev.yml logs -f decidim-dev
```

Now you can thoroughly test the migrations and any changes with production data before applying them to the production environment.

**Important Notes:**
- Make sure to sanitize sensitive data in the development environment if needed
- The development database will contain real user data, so handle it with care
- Consider running this process on a staging environment for additional safety

## Backups

Database is backup every day using https://github.com/tiredofit/docker-db-backup (see docker-compose.yml for details)

Backups are stored in:

- `backups/*`

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Open a Rails console in the server:

   **Production:**
   ```bash
   docker compose -f docker-compose-production.yml exec decidim bundle exec rails console
   ```

   **Staging:**
   ```bash
   docker compose -f docker-compose-staging.yml exec decidim-staging bundle exec rails console
   ```

   **Development:**
   ```bash
   docker compose -f docker-compose-dev.yml exec decidim-dev bundle exec rails console
   ```

2. Create a System Admin user:

```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

3. Visit `<your app url>/system` and login with your system admin credentials
4. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
5. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
6. Fill the rest of the form and submit it.

You're good to go!
