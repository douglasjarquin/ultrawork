#!/bin/bash

# Create the agents directory if it doesn't exist
mkdir -p ~/.copilot/agents/

# Copy all agent files
cp -v *.agent.md ~/.copilot/agents/

echo "✓ Agents installed to ~/.copilot/agents/"
