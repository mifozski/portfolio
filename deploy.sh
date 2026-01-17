#!/bin/bash

# Deployment script for portfolio site
# Deploys to 45.154.35.21 using nginx

set -e  # Exit on error

# Configuration
SERVER="45.154.35.21"
SERVER_USER="root"  # Change if you use a different user
DEPLOY_PATH="/var/www/html/portfolio"  # Change if you want a different path
NGINX_CONFIG_PATH="/etc/nginx/sites-available/mysticeggs.xyz"  # Adjust if needed
NGINX_SITE_NAME="mysticeggs.xyz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting deployment to ${SERVER}...${NC}"

# Check if rsync is available
if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync is not installed. Please install it first.${NC}"
    exit 1
fi

# Create deployment directory on server
echo -e "${YELLOW}Creating deployment directory on server...${NC}"
ssh ${SERVER_USER}@${SERVER} "mkdir -p ${DEPLOY_PATH}"

# Sync files to server (excluding node_modules, .git, etc.)
echo -e "${YELLOW}Syncing files to server...${NC}"
rsync -avz --delete \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.DS_Store' \
    --exclude '*.log' \
    --exclude 'package-lock.json' \
    --exclude '.gitignore' \
    ./ ${SERVER_USER}@${SERVER}:${DEPLOY_PATH}/

# Set proper permissions
echo -e "${YELLOW}Setting file permissions...${NC}"
ssh ${SERVER_USER}@${SERVER} "chown -R www-data:www-data ${DEPLOY_PATH} && chmod -R 755 ${DEPLOY_PATH}"

# Check if nginx config needs updating
echo -e "${YELLOW}Checking nginx configuration...${NC}"

# Check if portfolio config already exists
PORTFOLIO_CONFIGURED=$(ssh ${SERVER_USER}@${SERVER} "grep -q 'Portfolio site' ${NGINX_CONFIG_PATH} && echo 'yes' || echo 'no'")

if [ "$PORTFOLIO_CONFIGURED" = "yes" ]; then
    echo -e "${GREEN}Nginx config already contains portfolio configuration.${NC}"
else
    echo -e "${YELLOW}Updating nginx configuration for portfolio...${NC}"
    
    # Backup the config first
    BACKUP_FILE="${NGINX_CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    ssh ${SERVER_USER}@${SERVER} "cp ${NGINX_CONFIG_PATH} ${BACKUP_FILE}"
    echo -e "${GREEN}Config backed up to ${BACKUP_FILE}${NC}"
    
    # Create /portfolio/ location block snippet
    cat > /tmp/portfolio-location.txt << 'EOF'
    # Portfolio site - /portfolio/ alias
    location /portfolio/ {
        alias /var/www/html/portfolio/;
        try_files $uri $uri/ /portfolio/index.html;
        index index.html;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # Cache static assets
        location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot|JPG)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
EOF
    
    # Copy snippet to server
    scp /tmp/portfolio-location.txt ${SERVER_USER}@${SERVER}:/tmp/portfolio-location.txt
    
    # Insert /portfolio/ location before root location
    ssh ${SERVER_USER}@${SERVER} "sed -i '/location \/ {/r /tmp/portfolio-location.txt' ${NGINX_CONFIG_PATH} && rm /tmp/portfolio-location.txt"
    
    # Create root redirect blocks
    cat > /tmp/root-redirects.txt << 'EOF'
    # Root redirects to /portfolio/
    location = / {
        return 301 /portfolio/;
    }
    
    location / {
        return 301 /portfolio$request_uri;
    }
EOF
    scp /tmp/root-redirects.txt ${SERVER_USER}@${SERVER}:/tmp/root-redirects.txt
    
    # Replace the existing root location block with redirects
    # Use a simpler approach: find and replace the root location block
    ssh ${SERVER_USER}@${SERVER} "
        # Find the line number of 'location / {' 
        ROOT_LINE=\$(grep -n '^[[:space:]]*location[[:space:]]*/[[:space:]]*{' ${NGINX_CONFIG_PATH} | head -1 | cut -d: -f1)
        
        if [ ! -z \"\$ROOT_LINE\" ]; then
            # Find the matching closing brace (same indentation level)
            INDENT=\$(sed -n \"\${ROOT_LINE}p\" ${NGINX_CONFIG_PATH} | sed 's/[^ ].*//' | wc -c)
            INDENT=\$((INDENT - 1))
            
            # Find closing brace at same or less indentation
            END_LINE=\$(awk -v start=\"\$ROOT_LINE\" -v indent=\"\$INDENT\" '
                NR >= start {
                    line_indent = match(\$0, /[^ ]/) ? RSTART - 1 : 0
                    if (NR > start && /^[[:space:]]*}[[:space:]]*$/ && line_indent <= indent) {
                        print NR
                        exit
                    }
                }
            ' ${NGINX_CONFIG_PATH})
            
            if [ ! -z \"\$END_LINE\" ]; then
                # Delete the old root location block
                sed -i \"\${ROOT_LINE},\${END_LINE}d\" ${NGINX_CONFIG_PATH}
                # Insert redirect blocks before the line that was after root location
                sed -i \"\$((ROOT_LINE-1))r /tmp/root-redirects.txt\" ${NGINX_CONFIG_PATH}
            else
                echo -e \"${YELLOW}Warning: Could not find closing brace for root location. Using fallback method.${NC}\"
                # Fallback: replace content inside root location
                sed -i '/location \/ {/,/^[[:space:]]*}/ {
                    /location \/ {/! {
                        /^[[:space:]]*}/!d
                    }
                }' ${NGINX_CONFIG_PATH}
                sed -i '/location \/ {/r /tmp/root-redirects.txt' ${NGINX_CONFIG_PATH}
            fi
        else
            echo -e \"${YELLOW}Warning: Could not find root location block. Adding redirects before any location block.${NC}\"
            # Add before first location block or at end of server block
            sed -i '/location[[:space:]]/i\
    # Root redirects to /portfolio/\
    location = / {\
        return 301 /portfolio/;\
    }\
\
    location / {\
        return 301 /portfolio\$request_uri;\
    }' ${NGINX_CONFIG_PATH}
        fi
        
        rm -f /tmp/root-redirects.txt
    "
    
    # Clean up local temp files
    rm /tmp/portfolio-location.txt /tmp/root-redirects.txt 2>/dev/null || true
    
    echo -e "${GREEN}Nginx config updated.${NC}"
    echo -e "${YELLOW}Root location (/) now redirects to /portfolio/${NC}"
    echo -e "${YELLOW}/portfolio/ location serves the portfolio${NC}"
fi

# Test nginx configuration
echo -e "${YELLOW}Testing nginx configuration...${NC}"
if ssh ${SERVER_USER}@${SERVER} "nginx -t"; then
    echo -e "${GREEN}Nginx configuration is valid.${NC}"
    
    # Reload nginx
    echo -e "${YELLOW}Reloading nginx...${NC}"
    ssh ${SERVER_USER}@${SERVER} "systemctl reload nginx"
    echo -e "${GREEN}Nginx reloaded successfully.${NC}"
else
    echo -e "${RED}Error: Nginx configuration test failed. Please check manually.${NC}"
    exit 1
fi

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Your portfolio is available at:${NC}"
echo -e "${GREEN}  - https://mysticeggs.xyz/ (redirects to /portfolio/)${NC}"
echo -e "${GREEN}  - https://mysticeggs.xyz/portfolio/${NC}"
