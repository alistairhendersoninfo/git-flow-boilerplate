# Universal Documentation System

## 🎯 Overview

Comprehensive documentation generator supporting multiple languages and frameworks:
- **PHP** - PHPDoc, phpDocumentor
- **Python** - Sphinx, MkDocs, pydoc
- **React/JavaScript** - JSDoc, React Styleguidist
- **Angular/TypeScript** - TypeDoc, Compodoc
- **Bash** - Current GITFLOW system
- **Rust** - rustdoc, mdBook
- **API** - OpenAPI/Swagger, AsyncAPI
- **Static Sites** - MkDocs, Docusaurus, Hugo

## 📁 Directory Structure

```
.claude/docs/
├── UNIVERSAL-DOCUMENTATION-SYSTEM.md    # This file
├── generators/
│   ├── generate_php_docs.sh            # PHP documentation
│   ├── generate_python_docs.sh         # Python documentation
│   ├── generate_js_docs.sh             # JavaScript/React documentation
│   ├── generate_ts_docs.sh             # TypeScript/Angular documentation
│   ├── generate_rust_docs.sh           # Rust documentation
│   ├── generate_api_docs.sh            # API documentation
│   └── generate_all_docs.sh            # Master generator
├── templates/
│   ├── mkdocs.yml.template             # MkDocs configuration
│   ├── docusaurus.config.js.template   # Docusaurus configuration
│   ├── sphinx-conf.py.template         # Sphinx configuration
│   ├── typedoc.json.template           # TypeDoc configuration
│   └── phpdoc.xml.template             # PHPDoc configuration
└── static-sites/
    ├── setup_mkdocs.sh                 # MkDocs site setup
    ├── setup_docusaurus.sh             # Docusaurus site setup
    └── setup_github_pages.sh           # GitHub Pages setup
```

## 🔧 Language-Specific Documentation

### PHP Documentation

**Tools:**
- **phpDocumentor** - Standard PHP documentation
- **ApiGen** - Modern PHP API documentation
- **Doctum** - Fork of Sami, modern PHP docs

**Comment Format:**
```php
/**
 * Class description
 * 
 * @package    PackageName
 * @author     Your Name
 * @copyright  2024 Company
 * @license    MIT
 */
class MyClass {
    /**
     * Method description
     * 
     * @param  string $param Parameter description
     * @return bool   Return description
     * @throws Exception When something goes wrong
     */
    public function myMethod(string $param): bool {}
}
```

**Generation Command:**
```bash
# Using phpDocumentor
phpdoc -d src/ -t docs/api/

# Using Doctum
doctum.phar update config/doctum.php
```

### Python Documentation

**Tools:**
- **Sphinx** - Professional Python documentation
- **MkDocs** - Simple, markdown-based docs
- **pydoc** - Built-in Python documentation

**Docstring Format:**
```python
"""
Module description

This module provides functionality for...
"""

class MyClass:
    """
    Class description
    
    Attributes:
        attr1 (str): Description of attr1
        attr2 (int): Description of attr2
    """
    
    def my_method(self, param: str) -> bool:
        """
        Method description
        
        Args:
            param (str): Parameter description
            
        Returns:
            bool: Return description
            
        Raises:
            ValueError: When invalid input
            
        Examples:
            >>> obj = MyClass()
            >>> obj.my_method("test")
            True
        """
        pass
```

**Generation Command:**
```bash
# Using Sphinx
sphinx-build -b html source/ build/

# Using MkDocs
mkdocs build

# Using pydoc
pydoc -w ./src
```

### JavaScript/React Documentation

**Tools:**
- **JSDoc** - Standard JavaScript documentation
- **React Styleguidist** - React component documentation
- **Storybook** - Component development environment

**Comment Format:**
```javascript
/**
 * Component description
 * @component
 * @example
 * <MyComponent prop="value" />
 */

/**
 * Function description
 * @param {string} param - Parameter description
 * @param {Object} options - Options object
 * @param {boolean} options.flag - Flag description
 * @returns {Promise<string>} Return description
 * @throws {Error} When something goes wrong
 * @async
 */
async function myFunction(param, options = {}) {}

// React PropTypes documentation
MyComponent.propTypes = {
    /** The user's name */
    name: PropTypes.string.isRequired,
    /** Click handler */
    onClick: PropTypes.func
};
```

**Generation Command:**
```bash
# Using JSDoc
jsdoc -c jsdoc.json -r src/ -d docs/

# Using React Styleguidist
styleguidist build

# Using Storybook
npm run build-storybook
```

### TypeScript/Angular Documentation

**Tools:**
- **TypeDoc** - TypeScript documentation generator
- **Compodoc** - Angular application documentation
- **API Extractor** - Microsoft's TypeScript API docs

**Comment Format:**
```typescript
/**
 * Service description
 * @class
 * @implements {OnInit}
 */
@Injectable()
export class MyService implements OnInit {
    /**
     * Method description
     * @param param - Parameter description
     * @returns Observable of results
     * @throws {HttpError} When request fails
     * @example
     * ```typescript
     * service.myMethod('value').subscribe(result => {
     *   console.log(result);
     * });
     * ```
     */
    myMethod(param: string): Observable<Result> {}
}
```

**Generation Command:**
```bash
# Using TypeDoc
typedoc --out docs src

# Using Compodoc (Angular)
compodoc -p tsconfig.json -d docs

# Using API Extractor
api-extractor run --local
```

### Rust Documentation

**Tools:**
- **rustdoc** - Built-in Rust documentation
- **mdBook** - Create books from Markdown

**Comment Format:**
```rust
//! Module-level documentation
//! 
//! This module provides...

/// Structure documentation
/// 
/// # Examples
/// 
/// ```
/// let example = MyStruct::new();
/// ```
pub struct MyStruct {
    /// Field documentation
    pub field: String,
}

impl MyStruct {
    /// Method documentation
    /// 
    /// # Arguments
    /// 
    /// * `param` - Parameter description
    /// 
    /// # Returns
    /// 
    /// Returns description
    /// 
    /// # Errors
    /// 
    /// Returns `Error` when...
    pub fn my_method(&self, param: &str) -> Result<String, Error> {}
}
```

**Generation Command:**
```bash
# Using rustdoc
cargo doc --no-deps --open

# Using mdBook
mdbook build
```

### API Documentation

**Tools:**
- **OpenAPI/Swagger** - REST API documentation
- **AsyncAPI** - Event-driven API documentation
- **Postman** - API documentation and testing

**OpenAPI Format:**
```yaml
openapi: 3.0.0
info:
  title: API Title
  version: 1.0.0
  description: API Description
paths:
  /users:
    get:
      summary: Get users
      description: Retrieve a list of users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

**Generation Command:**
```bash
# Using Swagger UI
swagger-ui-dist preview openapi.yaml

# Using ReDoc
redoc-cli bundle openapi.yaml

# Using AsyncAPI
asyncapi generate fromTemplate asyncapi.yaml @asyncapi/html-template
```

## 🚀 Master Documentation Generator

### generate_all_docs.sh

```bash
#!/usr/bin/env bash
#
# Master documentation generator for all project types
# Detects project type and generates appropriate documentation

set -euo pipefail

# Detect project languages
detect_languages() {
    local languages=()
    
    [[ -f "composer.json" || -f "*.php" ]] && languages+=("php")
    [[ -f "requirements.txt" || -f "setup.py" || -f "*.py" ]] && languages+=("python")
    [[ -f "package.json" ]] && languages+=("javascript")
    [[ -f "tsconfig.json" ]] && languages+=("typescript")
    [[ -f "Cargo.toml" ]] && languages+=("rust")
    [[ -f "*.sh" ]] && languages+=("bash")
    [[ -f "openapi.yaml" || -f "swagger.json" ]] && languages+=("api")
    
    echo "${languages[@]}"
}

# Generate documentation for detected languages
main() {
    echo "Universal Documentation Generator"
    echo "================================"
    
    local languages=($(detect_languages))
    
    if [[ ${#languages[@]} -eq 0 ]]; then
        echo "No supported languages detected"
        exit 1
    fi
    
    echo "Detected languages: ${languages[*]}"
    echo ""
    
    for lang in "${languages[@]}"; do
        case "$lang" in
            php)
                ./generators/generate_php_docs.sh
                ;;
            python)
                ./generators/generate_python_docs.sh
                ;;
            javascript)
                ./generators/generate_js_docs.sh
                ;;
            typescript)
                ./generators/generate_ts_docs.sh
                ;;
            rust)
                ./generators/generate_rust_docs.sh
                ;;
            bash)
                # Use existing GITFLOW system
                ../scripts/generate_documentation.sh
                ;;
            api)
                ./generators/generate_api_docs.sh
                ;;
        esac
    done
    
    # Generate static site if configured
    if [[ -f "mkdocs.yml" ]]; then
        echo "Building MkDocs site..."
        mkdocs build
    elif [[ -f "docusaurus.config.js" ]]; then
        echo "Building Docusaurus site..."
        npm run build
    fi
    
    echo ""
    echo "Documentation generation complete!"
    echo "Output directory: ./docs/"
}

main "$@"
```

## 📚 Static Site Generators

### MkDocs Setup

**Configuration (mkdocs.yml):**
```yaml
site_name: Project Documentation
site_url: https://example.com
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - search.highlight
    
nav:
  - Home: index.md
  - API Reference: api/
  - User Guide: guide/
  - Contributing: contributing.md
  
plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          setup_commands:
            - import sys
            - sys.path.insert(0, "src")
        
markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences
  - pymdownx.tabbed
  - admonition
```

### Docusaurus Setup

**Configuration (docusaurus.config.js):**
```javascript
module.exports = {
  title: 'Project Documentation',
  tagline: 'Comprehensive project documentation',
  url: 'https://example.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  
  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/user/repo/edit/main/',
        },
        blog: false,
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
  
  themeConfig: {
    navbar: {
      title: 'Documentation',
      items: [
        {
          type: 'doc',
          docId: 'intro',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://github.com/user/repo',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
  },
};
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Generate Documentation

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    
    - name: Install documentation tools
      run: |
        npm install -g jsdoc typedoc @compodoc/compodoc
        pip install sphinx mkdocs mkdocs-material
        
    - name: Generate documentation
      run: |
        ./.claude/docs/generators/generate_all_docs.sh
        
    - name: Deploy to GitHub Pages
      if: github.ref == 'refs/heads/main'
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./docs
```

## 🎯 Best Practices

1. **Consistent Documentation Style**
   - Use same comment format across language
   - Include examples in documentation
   - Document all public APIs
   
2. **Automated Generation**
   - Run on every commit via hooks
   - Generate in CI/CD pipeline
   - Deploy to documentation site
   
3. **Documentation Coverage**
   - Track documentation coverage
   - Fail builds on missing docs
   - Regular documentation reviews
   
4. **Version Management**
   - Tag documentation with releases
   - Maintain historical versions
   - Clear migration guides

## 📋 Quick Start

```bash
# Install documentation system
cd .claude/docs
./install_doc_tools.sh

# Generate all documentation
./generators/generate_all_docs.sh

# Setup static site
./static-sites/setup_mkdocs.sh

# Deploy to GitHub Pages
./static-sites/setup_github_pages.sh
```

This universal system handles all your documentation needs across all languages and frameworks!