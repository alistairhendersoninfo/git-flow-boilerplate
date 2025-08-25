# Contributing to Universal Git Flow Boilerplate

Thank you for your interest in contributing to the Universal Git Flow Boilerplate! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### 🐛 Reporting Bugs

1. **Check existing issues** first to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Include relevant details**:
   - Operating system and version
   - Language/framework versions
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages or logs

### ✨ Suggesting Features

1. **Check the roadmap** in README.md first
2. **Use the feature request template**
3. **Explain the use case** and benefits
4. **Consider implementation complexity**

### 🔧 Code Contributions

#### Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/alistairhendersoninfo/git-flow-boilerplate.git
   cd git-flow-boilerplate
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```

#### Development Workflow

1. **Make your changes** following our coding standards
2. **Add tests** for new functionality
3. **Update documentation** as needed
4. **Run the test suite**:
   ```bash
   ./scripts/run-tests.sh
   ```
5. **Generate documentation**:
   ```bash
   ./scripts/generate-docs.sh
   ```
6. **Commit your changes**:
   ```bash
   git commit -m "feat: add amazing feature"
   ```
7. **Push to your fork**:
   ```bash
   git push origin feature/amazing-feature
   ```
8. **Create a Pull Request**

## 📋 Development Guidelines

### 🏗️ Adding New Languages

When adding support for a new programming language:

1. **Create example directory**: `examples/[language]/`
2. **Implement required components**:
   - CLI application with argument parsing
   - HTTP server with REST API
   - Comprehensive test suite
   - Documentation generation
3. **Add template directory**: `templates/[language]/`
4. **Update CI/CD pipeline**: `.github/workflows/ci.yml`
5. **Update setup script**: Add language to `setup.sh`
6. **Update documentation**: README.md, docs/, etc.

#### Required Features for Each Language

**CLI Application:**
- Multi-language greeting support (9+ languages)
- JSON and text output formats
- Argument parsing and validation
- Help and version information
- Error handling and user feedback

**HTTP Server:**
- RESTful API endpoints (`/`, `/greet`, `/health`, `/languages`)
- Query parameter support
- JSON responses
- Error handling
- Logging and monitoring

**Testing:**
- Unit tests with >90% coverage
- Integration tests for API endpoints
- Performance benchmarks
- Test automation scripts

**Documentation:**
- README with usage examples
- API documentation (auto-generated)
- Code comments and docstrings
- Integration with main docs site

### 🎨 Code Style Guidelines

#### General Principles
- **Consistency** - Follow existing patterns
- **Clarity** - Write self-documenting code
- **Simplicity** - Prefer simple solutions
- **Testing** - Write tests for new code

#### Language-Specific Standards

**Rust:**
- Use `cargo fmt` for formatting
- Pass `cargo clippy` without warnings
- Follow Rust naming conventions
- Use `cargo doc` for documentation

**Python:**
- Use Black for formatting
- Pass flake8 linting
- Use type hints where appropriate
- Follow PEP 8 guidelines
- Use docstrings for functions/classes

**Node.js/JavaScript:**
- Use Prettier for formatting
- Pass ESLint without errors
- Use JSDoc for documentation
- Follow modern ES6+ patterns

**Bash:**
- Pass shellcheck without errors
- Use consistent indentation (2 spaces)
- Include comprehensive error handling
- Add function documentation

**PHP:**
- Follow PSR-12 coding standards
- Use PHPStan for static analysis
- Include type declarations
- Use phpDocumentor comments

### 📝 Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(rust): add Rocket framework support
fix(python): resolve FastAPI dependency issue
docs: update getting started guide
test(nodejs): add integration tests for Express server
```

### 🧪 Testing Requirements

#### Test Coverage
- **Minimum 90% coverage** for new code
- **Unit tests** for all functions/methods
- **Integration tests** for API endpoints
- **End-to-end tests** for CLI applications

#### Test Organization
```
tests/
├── unit/           # Unit tests
├── integration/    # Integration tests
├── e2e/           # End-to-end tests
└── fixtures/      # Test data and fixtures
```

#### Running Tests
```bash
# Run all tests
./scripts/run-tests.sh

# Run tests for specific language
./scripts/run-tests.sh --language python

# Run with coverage
./scripts/run-tests.sh --coverage

# Run specific test type
./scripts/run-tests.sh --type unit
```

### 📚 Documentation Standards

#### Code Documentation
- **Functions/methods** must have docstrings/comments
- **Complex logic** should be explained
- **API endpoints** must be documented
- **Examples** should be included

#### README Files
- Each language example needs a README.md
- Include usage examples and setup instructions
- Document all available commands and options
- Provide troubleshooting information

#### API Documentation
- Use language-specific doc tools (rustdoc, Sphinx, JSDoc, etc.)
- Include examples for all endpoints
- Document request/response formats
- Provide authentication details if applicable

## 🔄 Pull Request Process

### Before Submitting

1. **Ensure all tests pass**
2. **Update documentation**
3. **Add changelog entry** if significant
4. **Rebase on latest main** if needed
5. **Write clear PR description**

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process

1. **Automated checks** must pass (CI/CD pipeline)
2. **Code review** by maintainers
3. **Testing** on multiple environments
4. **Documentation review**
5. **Final approval** and merge

## 🏷️ Release Process

### Version Numbering
We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps
1. Update version numbers
2. Update CHANGELOG.md
3. Create release branch
4. Final testing and validation
5. Merge to main
6. Create GitHub release
7. Deploy documentation

## 🤝 Community Guidelines

### Code of Conduct
- **Be respectful** and inclusive
- **Help others** learn and grow
- **Give constructive feedback**
- **Focus on the code**, not the person

### Communication
- **Use clear, concise language**
- **Provide context** for issues and PRs
- **Be patient** with review process
- **Ask questions** if unclear

### Recognition
Contributors are recognized in:
- README.md acknowledgments
- Release notes
- GitHub contributors page
- Special recognition for major contributions

## 📞 Getting Help

### Resources
- 📖 [Documentation](https://alistairhendersoninfo.github.io/git-flow-boilerplate)
- 💬 [Discussions](https://github.com/alistairhendersoninfo/git-flow-boilerplate/discussions)
- 🐛 [Issues](https://github.com/alistairhendersoninfo/git-flow-boilerplate/issues)

### Contact
- **General questions**: Use GitHub Discussions
- **Bug reports**: Create GitHub Issues
- **Security issues**: Email security@example.com
- **Direct contact**: Email dev@example.com

## 🙏 Thank You

Every contribution, no matter how small, helps make this project better for everyone. Thank you for taking the time to contribute!

---

**Happy Contributing! 🚀**