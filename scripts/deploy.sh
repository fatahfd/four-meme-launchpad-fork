#!/bin/bash

# Four.Meme Launchpad Deployment Script
# This script automates the deployment process for the entire platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-development}
NETWORK=${2:-bsc-testnet}

echo -e "${BLUE}🚀 Four.Meme Launchpad Deployment Script${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Network: ${NETWORK}${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Install dependencies
install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    
    # Root dependencies
    npm install
    print_status "Root dependencies installed"
    
    # Smart contract dependencies
    cd smartcontract
    npm install
    print_status "Smart contract dependencies installed"
    cd ..
    
    # Backend dependencies
    cd backend
    npm install
    print_status "Backend dependencies installed"
    cd ..
    
    # Frontend dependencies
    cd frontend
    npm install
    print_status "Frontend dependencies installed"
    cd ..
}

# Build smart contracts
build_smartcontracts() {
    echo -e "${BLUE}🔨 Building smart contracts...${NC}"
    
    cd smartcontract
    
    # Compile contracts
    npx hardhat compile
    print_status "Smart contracts compiled"
    
    # Run tests
    npx hardhat test
    print_status "Smart contract tests passed"
    
    cd ..
}

# Deploy smart contracts
deploy_smartcontracts() {
    echo -e "${BLUE}🚀 Deploying smart contracts...${NC}"
    
    cd smartcontract
    
    # Deploy to specified network
    npx hardhat deploy --network $NETWORK
    print_status "Smart contracts deployed to $NETWORK"
    
    cd ..
}

# Build backend
build_backend() {
    echo -e "${BLUE}🔨 Building backend...${NC}"
    
    cd backend
    
    # Type check
    npm run type-check
    print_status "Backend type check passed"
    
    # Build
    npm run build
    print_status "Backend built successfully"
    
    cd ..
}

# Build frontend
build_frontend() {
    echo -e "${BLUE}🔨 Building frontend...${NC}"
    
    cd frontend
    
    # Type check
    npm run type-check
    print_status "Frontend type check passed"
    
    # Build
    npm run build
    print_status "Frontend built successfully"
    
    cd ..
}

# Run tests
run_tests() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    
    # Smart contract tests
    cd smartcontract
    npm test
    print_status "Smart contract tests passed"
    cd ..
    
    # Backend tests
    cd backend
    npm test
    print_status "Backend tests passed"
    cd ..
    
    # Frontend tests
    cd frontend
    npm test
    print_status "Frontend tests passed"
    cd ..
}

# Start services
start_services() {
    echo -e "${BLUE}🚀 Starting services...${NC}"
    
    if [ "$ENVIRONMENT" = "development" ]; then
        # Start development servers
        npm run dev &
        print_status "Development servers started"
    else
        # Start production servers
        cd backend
        npm start &
        print_status "Backend server started"
        cd ..
        
        cd frontend
        npm start &
        print_status "Frontend server started"
        cd ..
    fi
}

# Main deployment function
deploy() {
    echo -e "${BLUE}🎯 Starting deployment process...${NC}"
    
    check_prerequisites
    install_dependencies
    
    if [ "$ENVIRONMENT" = "production" ]; then
        run_tests
        build_smartcontracts
        deploy_smartcontracts
        build_backend
        build_frontend
    fi
    
    print_status "Deployment completed successfully!"
    echo ""
    echo -e "${GREEN}🎉 Four.Meme Launchpad is ready!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Configure environment variables"
    echo "2. Start MongoDB and Redis services"
    echo "3. Run 'npm run dev' to start development servers"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "- README.md for setup instructions"
    echo "- docs/ for detailed documentation"
    echo "- CONTRIBUTING.md for contribution guidelines"
}

# Handle script arguments
case "$1" in
    "help"|"-h"|"--help")
        echo "Usage: $0 [environment] [network]"
        echo ""
        echo "Environments:"
        echo "  development  - Development environment (default)"
        echo "  production   - Production environment"
        echo ""
        echo "Networks:"
        echo "  bsc-testnet  - BSC Testnet (default)"
        echo "  bsc          - BSC Mainnet"
        echo ""
        echo "Examples:"
        echo "  $0                    # Development on BSC Testnet"
        echo "  $0 production bsc    # Production on BSC Mainnet"
        echo "  $0 development bsc   # Development on BSC Mainnet"
        ;;
    *)
        deploy
        ;;
esac
