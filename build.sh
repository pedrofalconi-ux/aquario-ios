#!/bin/bash

# Target Xcode installation path
DEVELOPER_DIR="/Users/pedrohenriquefalconi/Downloads/Xcode.app/Contents/Developer"
export DEVELOPER_DIR

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Aquario-App build automation...${NC}"

# Clean build option
if [ "$1" == "clean" ]; then
    echo -e "${YELLOW}Cleaning build files...${NC}"
    xcodebuild -scheme Aquario-App -destination 'platform=iOS Simulator,name=iPhone 14' clean
fi

# Run the build
echo -e "${YELLOW}Compiling project with xcodebuild...${NC}"
xcodebuild -scheme Aquario-App -destination 'platform=iOS Simulator,name=iPhone 14' build

# Check build status
if [ $? -eq 0 ]; then
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}         BUILD SUCCEEDED! 🎉             ${NC}"
    echo -e "${GREEN}=========================================${NC}"
    exit 0
else
    echo -e "${RED}=========================================${NC}"
    echo -e "${RED}         BUILD FAILED! ❌                ${NC}"
    echo -e "${RED}=========================================${NC}"
    exit 1
fi
