# Smart Contracts CI/CD Pipeline

A comprehensive CI/CD pipeline for secure smart contract development and deployment on Ethereum networks.

## 🚀 Features

- **Automated Testing**: Comprehensive test suite with Hardhat and Mocha
- **Security Scanning**: Integration with Slither and Solhint for vulnerability detection
- **Automated Deployment**: CI/CD pipeline for testnet and mainnet deployment
- **Contract Verification**: Automatic verification on Etherscan
- **Multi-Network Support**: Local, Goerli, Sepolia, and Mainnet deployment
- **Gas Optimization**: Built-in gas reporting and optimization

## 🛠️ Prerequisites

- Node.js 18+ and npm
- Git and GitHub account
- Ethereum wallet with testnet ETH (for Goerli/Sepolia)
- Infura API key
- Etherscan API key

## 📦 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smart-contracts-ci-cd.git
   cd smart-contracts-ci-cd
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your actual API keys and private keys
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
INFURA_API_KEY=your_infura_api_key_here
PRIVATE_KEY=your_wallet_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here
REPORT_GAS=true
```

### GitHub Secrets

Add the following secrets to your GitHub repository:

1. Go to **Settings → Secrets → Actions**
2. Add:
   - `INFURA_API_KEY`: Your Infura API key
   - `PRIVATE_KEY`: Your wallet's private key
   - `ETHERSCAN_API_KEY`: Your Etherscan API key

## 🧪 Testing

### Run Tests
```bash
npm test                    # Run all tests
npm run test:coverage      # Run tests with coverage
```

### Run Linting
```bash
npm run lint               # Check Solidity code quality
npm run lint:fix           # Auto-fix linting issues
```

### Security Analysis
```bash
npm run security           # Run Slither analysis (requires Python)
```

## 🚀 Deployment

### Local Development
```bash
npm run node               # Start local Hardhat node
npm run deploy:local       # Deploy to local network
```

### Testnet Deployment
```bash
npm run deploy:goerli      # Deploy to Goerli testnet
npm run deploy:sepolia     # Deploy to Sepolia testnet
```

### Contract Verification
```bash
npm run verify:goerli      # Verify on Goerli Etherscan
npm run verify:sepolia     # Verify on Sepolia Etherscan
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Build**: Compiles contracts and runs tests
2. **Security**: Performs linting and security analysis
3. **Deploy**: Deploys to Goerli testnet (main branch only)
4. **Verify**: Verifies contracts on Etherscan

### Workflow Triggers
- **Push to main**: Triggers full pipeline including deployment
- **Pull Request**: Runs build and security checks only

## 📁 Project Structure

```
├── contracts/              # Smart contract source code
├── scripts/                # Deployment and utility scripts
├── test/                   # Test files
├── .github/workflows/      # GitHub Actions CI/CD
├── hardhat.config.ts       # Hardhat configuration
├── .solhint.json          # Solidity linting rules
├── TOOLS.md               # Complete tools documentation
└── README.md              # This file
```

## 🛡️ Security Features

- **Static Analysis**: Slither integration for vulnerability detection
- **Code Quality**: Solhint linting for Solidity best practices
- **Automated Testing**: Comprehensive test coverage
- **Gas Optimization**: Built-in gas reporting and analysis
- **Multi-Network Testing**: Local and testnet validation

## 🔗 Networks

| Network | Chain ID | Purpose | RPC URL |
|---------|----------|---------|---------|
| Hardhat | 31337 | Local development | http://127.0.0.1:8545 |
| Goerli | 5 | Testnet deployment | Infura Goerli |
| Sepolia | 11155111 | Testnet deployment | Infura Sepolia |
| Mainnet | 1 | Production (manual) | Infura Mainnet |

## 📊 Monitoring

- **GitHub Actions**: Pipeline execution monitoring
- **Etherscan**: Contract verification and interaction tracking
- **Gas Reports**: Automated gas usage analysis

## 🚨 Troubleshooting

### Common Issues

1. **Compilation Errors**: Check Solidity version compatibility
2. **Deployment Failures**: Verify network configuration and gas settings
3. **Verification Issues**: Ensure Etherscan API key is correct
4. **Test Failures**: Check network connectivity and contract state

### Getting Help

- Check the [Hardhat documentation](https://hardhat.org/docs)
- Review [Etherscan verification guide](https://docs.etherscan.io/)
- Open an issue in this repository

## 🔮 Next Steps

- [ ] Add fuzz testing with Echidna
- [ ] Implement mainnet deployment with manual approval
- [ ] Add monitoring with Prometheus + Grafana
- [ ] Implement automated rollback functionality
- [ ] Add multi-signature deployment support

## 📄 License

This project is licensed under the ISC License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

---

**⚠️ Security Notice**: Never commit private keys or sensitive information to version control. Always use environment variables and GitHub secrets for sensitive data.