# Contributing to Four.Meme Launchpad

Thank you for your interest in contributing to Four.Meme Launchpad! This document provides guidelines and information for contributors.

## Contact me on Telegram to build your own launchpad
<a href="https://t.me/cashblaze129" target="_blank">
  <img src="https://img.shields.io/badge/Telegram-@Contact_Me-0088cc?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Support" />
</a>

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- Git
- Basic knowledge of React, TypeScript, and Solidity
- Understanding of blockchain and DeFi concepts

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Install dependencies: `npm install`
4. Set up environment variables
5. Start development servers: `npm run dev`

## 📋 Contribution Guidelines

### Code Standards
- **TypeScript**: Use strict typing, avoid `any`
- **ESLint**: Follow the configured ESLint rules
- **Prettier**: Use Prettier for code formatting
- **Conventional Commits**: Use conventional commit messages
- **Test Coverage**: Maintain at least 80% test coverage

### Pull Request Process
1. Create a feature branch from `main`
2. Make your changes
3. Add tests for new functionality
4. Ensure all tests pass
5. Update documentation if needed
6. Submit a pull request

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 🧪 Testing

### Running Tests
```bash
# All tests
npm test

# Smart contract tests
cd smartcontract && npm test

# Backend tests
cd backend && npm test

# Frontend tests
cd frontend && npm test
```

### Writing Tests
- Write unit tests for all new functions
- Include integration tests for API endpoints
- Test error cases and edge conditions
- Mock external dependencies

## 📚 Documentation

### Code Documentation
- Document all public functions and classes
- Use JSDoc for TypeScript functions
- Include examples for complex functions
- Update README files when adding new features

### API Documentation
- Document all API endpoints
- Include request/response examples
- Document error codes and messages
- Update OpenAPI/Swagger specs

## 🐛 Bug Reports

When reporting bugs, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Screenshots if applicable

## 💡 Feature Requests

For feature requests, please:
- Describe the feature clearly
- Explain the use case
- Consider implementation complexity
- Check existing issues first

## 🔒 Security

### Security Issues
- Report security issues privately to security@four-meme-launchpad.com
- Do not create public issues for security vulnerabilities
- Include detailed reproduction steps
- Allow time for fixes before public disclosure

### Security Guidelines
- Never commit private keys or sensitive data
- Use environment variables for configuration
- Validate all user inputs
- Follow secure coding practices

## 📝 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🤝 Community

- Join our Discord for discussions
- Follow us on Twitter for updates
- Check our Telegram for announcements

Thank you for contributing to Four.Meme Launchpad! 🚀
