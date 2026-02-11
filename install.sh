#!/bin/bash

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse flags
REMOTE_HOST=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --remote)
            REMOTE_HOST="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--remote SSH_HOST]"
            exit 1
            ;;
    esac
done

echo "Validating YAML frontmatter..."

# Check if yamllint is installed
if ! command -v yamllint &> /dev/null; then
    echo -e "${RED}✖ yamllint is not installed.${NC}"
    echo "Install with: brew install yamllint"
    exit 1
fi

# Run validation
if ! ./validate.sh; then
    echo -e "\n${RED}✖ YAML validation failed. Please fix the errors above before installing.${NC}"
    exit 1
fi

echo ""

if [ -n "$REMOTE_HOST" ]; then
    # Remote installation via SSH
    echo -e "${YELLOW}Installing to remote host: $REMOTE_HOST${NC}"
    
    # Create the agents directory on remote host
    ssh "$REMOTE_HOST" "mkdir -p ~/.copilot/agents/"
    
    # Copy all agent files
    echo "Installing agents..."
    scp -v *.agent.md "$REMOTE_HOST:~/.copilot/agents/"
    
    # Copy shared configuration files
    echo "Installing shared configuration..."
    scp -v AGENTS.md handoff-protocol.md "$REMOTE_HOST:~/.copilot/agents/"
    
    echo ""
    echo -e "${GREEN}✓ Remote installation complete!${NC}"
    echo ""
    echo "Installed files on $REMOTE_HOST:"
    echo "  - Agents: $(ls -1 *.agent.md | wc -l | tr -d ' ') agent files"
    echo "  - Config: AGENTS.md"
    echo "  - Protocol: handoff-protocol.md"
    echo ""
    echo "All files installed to: $REMOTE_HOST:~/.copilot/agents/"
else
    # Local installation
    # Create the agents directory if it doesn't exist
    mkdir -p ~/.copilot/agents/
    
    # Copy all agent files
    echo "Installing agents..."
    cp -v *.agent.md ~/.copilot/agents/
    
    # Copy shared configuration files
    echo "Installing shared configuration..."
    cp -v AGENTS.md ~/.copilot/agents/
    cp -v handoff-protocol.md ~/.copilot/agents/
    
    echo ""
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo ""
    echo "Installed files:"
    echo "  - Agents: $(ls -1 *.agent.md | wc -l | tr -d ' ') agent files"
    echo "  - Config: AGENTS.md"
    echo "  - Protocol: handoff-protocol.md"
    echo ""
    echo "All files installed to: ~/.copilot/agents/"
fi
