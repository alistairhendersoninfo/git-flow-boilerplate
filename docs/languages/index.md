---
layout: page
title: Languages
permalink: /languages/
---

# Supported Languages

The Universal Git Flow Boilerplate supports multiple programming languages with comprehensive examples and templates.

## 🦀 Rust

**Status**: ✅ Complete  
**Framework**: Actix Web  
**Features**: CLI + HTTP Server, Cargo integration, comprehensive testing

### Example Files
- [CLI Application](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/src/main.rs)
- [HTTP Server](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/src/server.rs)
- [Cargo Configuration](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/Cargo.toml)

### Quick Start
```bash
cd examples/rust
cargo run --bin hello -- --name "Rust" --language "es"
cargo run --bin server
```

## 🐍 Python

**Status**: ✅ Complete  
**Framework**: FastAPI  
**Features**: CLI + HTTP Server, pytest testing, Sphinx documentation

### Example Files
- [CLI Application](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/hello.py)
- [FastAPI Server](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/server.py)
- [Test Suite](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/test_hello.py)

### Quick Start
```bash
cd examples/python
pip install -r requirements.txt
python hello.py --name "Python" --format json
python server.py
```

## 🟢 Node.js

**Status**: ✅ Complete  
**Framework**: Express  
**Features**: CLI + HTTP Server, Jest testing, JSDoc documentation

### Example Files
- [CLI Application](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/hello.js)
- [Express Server](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/server.js)
- [Test Suite](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/hello.test.js)

### Quick Start
```bash
cd examples/nodejs
npm install
node hello.js --name "Node.js" --language "fr"
npm start
```

## 🐚 Bash

**Status**: ✅ Complete  
**Framework**: Native Shell + netcat  
**Features**: CLI + HTTP Server, comprehensive testing

### Example Files
- [CLI Application](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/hello.sh)
- [HTTP Server](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/server.sh)
- [Test Suite](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/test_hello.sh)

### Quick Start
```bash
cd examples/bash
./hello.sh --name "Bash" --language "de"
./server.sh --port 8080
```

## 🚧 Planned Languages

### PHP
**Status**: 📋 Planned  
**Framework**: Slim Framework  
**Features**: CLI + HTTP Server, PHPUnit testing

### JavaScript (Vanilla)
**Status**: 📋 Planned  
**Framework**: Native + modern ES6+  
**Features**: Browser + Node.js examples

### React
**Status**: 📋 Planned  
**Framework**: Create React App + TypeScript  
**Features**: Modern React with hooks, testing library

### Vue.js
**Status**: 📋 Planned  
**Framework**: Vue 3 + Composition API  
**Features**: Modern Vue with TypeScript support

## 🔧 Language Features Comparison

| Language | CLI | Server | Tests | Docs | Status |
|----------|-----|--------|-------|------|--------|
| Rust     | ✅  | ✅     | ✅    | ✅   | Complete |
| Python   | ✅  | ✅     | ✅    | ✅   | Complete |
| Node.js  | ✅  | ✅     | ✅    | ✅   | Complete |
| Bash     | ✅  | ✅     | ✅    | ✅   | Complete |
| PHP      | 📋  | 📋     | 📋    | 📋   | Planned |
| JavaScript | 📋 | 📋     | 📋    | 📋   | Planned |
| React    | 📋  | 📋     | 📋    | 📋   | Planned |
| Vue.js   | 📋  | 📋     | 📋    | 📋   | Planned |

## 🌍 Multi-Language Support

All language implementations support:

- **9 Languages**: English, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Chinese
- **Consistent API**: Same endpoints and response format across all languages
- **JSON Output**: Structured data format for integration
- **Health Checks**: Monitoring and status endpoints
- **Error Handling**: Graceful error responses

## 🚀 Getting Started

1. **Choose your language** from the supported options above
2. **Navigate to the example directory**: `cd examples/[language]`
3. **Follow the Quick Start** instructions for that language
4. **Use the setup script** to create new projects: `./setup.sh --language [language] --name my-project`

## 📚 Next Steps

- [Getting Started Guide](/getting-started/)
- [API Documentation](/api/)
- [Workflows and CI/CD](/workflows/)
- [GitHub Repository](https://github.com/alistairhendersoninfo/git-flow-boilerplate)