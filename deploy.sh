#!/bin/bash

# Deployment script for portfolio site
# Deploys to 45.154.35.21

set -e  # Exit on error

# Configuration
SERVER="45.154.35.21"
SERVER_USER="root"  # Change if you use a different user
DEPLOY_PATH="/var/www/html/portfolio"  # Change if you want a different path

# Parse command line arguments
DRY_RUN=false
USE_CHECKSUM=false
SHOW_PROGRESS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --checksum|-c)
            USE_CHECKSUM=true
            shift
            ;;
        --no-progress)
            SHOW_PROGRESS=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run|-n] [--checksum|-c] [--no-progress]"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}=== DRY RUN MODE - No files will be transferred ===${NC}"
fi

echo -e "${GREEN}Starting deployment to ${SERVER}...${NC}"

# Check if rsync is available
if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync is not installed. Please install it first.${NC}"
    exit 1
fi

# Create deployment directory on server
if [ "$DRY_RUN" = false ]; then
    echo -e "${YELLOW}Creating deployment directory on server...${NC}"
    ssh ${SERVER_USER}@${SERVER} "mkdir -p ${DEPLOY_PATH}"
fi

# Build rsync command with smart options
RSYNC_OPTS="-avz --delete"

# Add checksum option if requested (more accurate but slower)
if [ "$USE_CHECKSUM" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --checksum"
    echo -e "${BLUE}Using checksum comparison for file changes (slower but more accurate)${NC}"
fi

# Add progress and itemize changes for better visibility
if [ "$SHOW_PROGRESS" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --progress --human-readable"
fi

# Add partial transfer support (resume interrupted transfers)
RSYNC_OPTS="$RSYNC_OPTS --partial --partial-dir=.rsync-partial"

# Add itemize changes to show what's being transferred
RSYNC_OPTS="$RSYNC_OPTS --itemize-changes"

# Add dry-run if requested
if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
fi

# Sync files to server (excluding node_modules, .git, etc.)
echo -e "${YELLOW}Syncing files to server (rsync will only transfer changed files)...${NC}"
echo -e "${BLUE}File change indicators:${NC}"
echo -e "${BLUE}  >f = file is being transferred${NC}"
echo -e "${BLUE}  .f = file is up to date${NC}"
echo -e "${BLUE}  *deleting = file is being deleted${NC}"
echo ""

rsync $RSYNC_OPTS \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.DS_Store' \
    --exclude '*.log' \
    --exclude 'package-lock.json' \
    --exclude '.gitignore' \
    --exclude '.rsync-partial' \
    ./ ${SERVER_USER}@${SERVER}:${DEPLOY_PATH}/

# Count transferred files (if not dry run)
if [ "$DRY_RUN" = false ]; then
    # Set proper permissions
    echo -e "${YELLOW}Setting file permissions...${NC}"
    ssh ${SERVER_USER}@${SERVER} "chown -R www-data:www-data ${DEPLOY_PATH} && chmod -R 755 ${DEPLOY_PATH}"
    
    # Reload nginx to apply changes
    echo -e "${YELLOW}Reloading nginx...${NC}"
    ssh ${SERVER_USER}@${SERVER} "systemctl reload nginx"
    echo -e "${GREEN}Nginx reloaded successfully.${NC}"
else
    echo -e "${BLUE}Skipping permission changes and nginx reload (dry run)${NC}"
fi

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Your portfolio is available at:${NC}"
echo -e "${GREEN}  - https://mysticeggs.xyz/portfolio/${NC}"
