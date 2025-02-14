# Keycloak + PostgreSQL + Nginx + Certbot in a Docker Compose Stack

## Introduction

This project sets up a secure Keycloak server using PostgreSQL as the database, Nginx as a reverse proxy, and Certbot for SSL certificates, all managed through Docker Compose.

## Prerequisites

Before starting, ensure you have the following:

- **VM with IP Address** (on GCP or any cloud provider): Make sure it’s configured and running with open ports 80 (HTTP) and 443 (HTTPS).
- **A valid domain name and DNS pointing every subdomain to IP address.** - use Cloudflare (?)
- **Docker** on VM (test with `docker compose version`)
- **JAVA** on VM (min 17, test with `java -version`)

## Installation

### 1. Clone the Repository

Scripts are meant to work within working directory `/home/vmtryondro`. So consider that by creating such dir and work
in it or adjust the code to point to your directory.

First, clone the repository from GitHub:
```bash
git clone https://github.com/piskula/keycloak-production.git
cd keycloak-production
```

### 2. Configure Environment Variables

Copy the provided `.env.example` to `.env`, `cloudflare.ini.example` to `cloudflare.ini` and adjust the variables to fit your setup:
```bash
cp .env.example .env
```
```bash
cp cloudflare.ini.example cloudflare.ini
```

Update the following in the `.env` file:
- `KEYCLOAK_DOMAIN`: Your valid domain name
  - you might need to adjust `KEYCLOAK_DOMAIN_ALTERNATIVE` and `CHARGING_DOMAIN` but should be fine
- `CERTBOT_LETSENCRYPT_EMAIL`: Your email address for SSL certificate registration.
- `POSTGRES_DB_PASSWORD`: Change default DB password (consider also changing user).
- `KEYCLOAK_CLIENT_ID`, `KEYCLOAK_CLIENT_SECRET` with configured realm client credentials
- `STATION_XXX` credentials, (URL for connection and Bearer auth token)

Update the following in the `cloudflare.ini` file:
- `dns_cloudflare_api_token`: Your API token from cloudflare.

### 3. SSL Setup (Run First)

Before starting the main stack, set up SSL certificates for your domain:

1. Make sure your domain is properly configured and pointing to your server.
   - add all subdomains and link them to IP address of the VM
2. Ensure ports **80** and **443** are open.
3. Ensure all relevant ENVIRONMENT variables are taken into account when resolving certificates, or apply them manually
4. Change Cloudflare SSL/TLS encryption to Full!
5. Run the SSL setup using Certbot and wait for certificates resolution:
```bash
sudo docker compose -f docker-compose-ssl.yml up
```

### 4. Start the Main Stack
Before starting main stack, make sure those 2 environment variables are available globally:
- `POSTGRES_DB_PASSWORD`
- `KEYCLOAK_DOMAIN`

For this purpose you can edit `/etc/environment` file and reboot the system.

With SSL certificates in place, start the entire stack:
```bash
sudo docker compose up -d
```
This will launch Keycloak, PostgreSQL, and Nginx, all configured to use SSL.

after this is done check that keycloak is reachable
- if there are neverending redirects or complains about not-secure page
    - certificates were not fetched properly
    - make sure env variables are not ignored

### 5. Configure keycloak
- login to keycloak admin console
- create new realm `momosi`
- create new client `kutlikova`
  - client auth `ON`
  - authorization `OFF`
  - auth flow `STANDARD`, rest `OFF`
  - set ROOT URL and Valid Redirect URL same as root with `/*` plus if needed also `localhost:4200/*` for local development
- note down client-id and client-secret
- create new role MOMO_ADMIN
  - optionally you can add MOMO_USER and add him to default roles so it is inherited automatically
- configure role mapping
  - go to client `kutlikova` -> client scopes -> add predefined mapper -> `realm roles`
  - change role mapping to work also for id token (`Add to ID token` option)

### 6. Run application (setup running charging as a service)
- You need to ensure `POSTGRES_DB_PASSWORD` (global) environment variable is set (is used in startup script)
  - you need to run `export POSTGRES_DB_PASSWORD=[value]`
- copy [charging-service.service](service/charging-service.service) into `/etc/systemd/system`
  - you can run `sudo cp service/charging-service.service /etc/systemd/system/charging-service.service`
- make sure paths inside [charging-service](service/charging-service.service) do match and also make sure user is same as current user.
- `sudo systemctl daemon-reload`
- `sudo systemctl start charging-service.service`
- you can check the status with `sudo systemctl status charging-service.service`

### 7. Set Up Automatic Certificate Renewal

To keep your SSL certificates updated, configure `crontab` to renew them automatically every 12 hours:

```bash
crontab -e
```

Add the following entry to run the renewal command:

```bash
0 */12 * * * docker compose run --rm certbot
```

## Port-Forward
We often need to be able to reach into our VM through port-forward. When configuring e.g. with Putty, you need to
specify source and destination in following way
- `source` is address on your local machine
- `destination` is address on VM

in Putty forwarding port 5432 inside VM to 5433 on our machine will look like:
`L5433 (source) - localhost:5432 (VM)`

## Keycloak Admin Information

- Default admin username: `admin`
- Default admin password: `admin`

These can be changed in the `.env` file under `KEYCLOAK_ADMIN` and `KEYCLOAK_ADMIN_PASSWORD`.

## Configuration

All configuration is managed through environment variables in the `.env` file:

| **Variable**                | **Description**                        | **Default Value** | **Required** |
|-----------------------------|----------------------------------------|-------------------|--------------|
| `KEYCLOAK_DOMAIN`           | Domain for the Keycloak server         |                   | Yes          |
| `CERTBOT_LETSENCRYPT_EMAIL` | Email for Let's Encrypt registration   |                   | Yes          |
| `SUBNET`                    | Subnet for container network           | 172.16.0.0/29     | No           |
| `KEYCLOAK_VERSION`          | Keycloak image version                 | latest            | No           |
| `POSTGRES_VERSION`          | PostgreSQL image version               | latest            | No           |
| `POSTGRES_DB_PASSWORD`      | Password for Keycloak PostgreSQL user  | defaultDbPassword | **No !!!**   |
| `NGINX_VERSION`             | Nginx image version                    | latest            | No           |
| `CERTBOT_VERSION`           | Certbot image version                  | latest            | No           |

## Contributing

Feel free to contribute by:

- Submitting a pull request with new features or bug fixes.
- Helping users by answering questions and resolving issues.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
