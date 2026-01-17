# Deployment Guide

This guide explains how to deploy the portfolio site to your server at `45.154.35.21`.

## Prerequisites

1. **SSH Access**: You need SSH access to the server with the appropriate user (default: `root`)
2. **rsync**: Required on your local machine for file syncing
3. **Nginx**: Already configured on your server

## Quick Deploy

Simply run:

```bash
npm run deploy
```

Or directly:

```bash
./deploy.sh
```

## What the Script Does

1. **Syncs Files**: Uses `rsync` to copy all files to `/var/www/html/portfolio/` on the server
2. **Sets Permissions**: Ensures files are owned by `www-data` with proper permissions
3. **Updates Nginx Config**: Adds a location block for `/portfolio/` to your nginx config
4. **Reloads Nginx**: Tests and reloads nginx configuration

## Configuration

You can customize the deployment by editing variables at the top of `deploy.sh`:

```bash
SERVER="45.154.35.21"
SERVER_USER="root"  # Change if you use a different user
DEPLOY_PATH="/var/www/html/portfolio"  # Change deployment path
NGINX_CONFIG_PATH="/etc/nginx/sites-available/mysticeggs.xyz"  # Adjust nginx config path
```

## Nginx Configuration

The script automatically updates your nginx config to:

1. **Serve portfolio from root** (`/`) - The root location block is updated to serve files from `/var/www/html/portfolio/`
2. **Add `/portfolio/` alias** - Also accessible via `/portfolio/` path

Both URLs will work:
- `https://mysticeggs.xyz/` → serves portfolio
- `https://mysticeggs.xyz/portfolio/` → also serves portfolio

The script:
- Updates the root location to point to the portfolio directory
- Adds a `/portfolio/` location block as an alias
- Adds security headers and caching for static assets
- Creates a backup of your config before making changes

## Manual Nginx Configuration

If you prefer to add the nginx config manually, you can:

1. Edit `/etc/nginx/sites-available/mysticeggs.xyz`
2. Add the configuration from `nginx-config-snippet.conf` before the root location block
3. Test: `nginx -t`
4. Reload: `systemctl reload nginx`

## Accessing the Site

After deployment, your portfolio will be available at:

- **https://mysticeggs.xyz/** (root - primary)
- **https://mysticeggs.xyz/portfolio/** (alias - also works)

## Troubleshooting

### SSH Connection Issues

If you get SSH connection errors:
- Check that you have SSH access to the server
- Verify the server IP is correct
- Ensure your SSH key is set up or you have password access

### Permission Issues

If you get permission errors:
- Make sure the user specified in `SERVER_USER` has sudo/root access
- Check that the deployment path exists and is writable

### Nginx Config Errors

If nginx config test fails:
- SSH to the server and check the config: `nginx -t`
- Review the added location block for syntax errors
- Check nginx error logs: `tail -f /var/log/nginx/error.log`

### Files Not Updating

If files aren't updating:
- Check that rsync completed successfully
- Verify file permissions: `ls -la /var/www/html/portfolio/`
- Clear browser cache

## Excluded Files

The deployment script excludes:
- `node_modules/`
- `.git/`
- `.DS_Store`
- `*.log`
- `package-lock.json`
- `.gitignore`

These files are not needed on the production server.
