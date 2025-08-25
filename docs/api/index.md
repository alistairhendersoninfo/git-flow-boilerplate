---
layout: page
title: API Documentation
permalink: /api/
---

# API Documentation

This section contains comprehensive API documentation for all language implementations in the Universal Git Flow Boilerplate.

## 🚀 Universal API

All language implementations provide the same REST API interface for consistency and interoperability.

### Base URL
- **Development**: `http://localhost:PORT`
- **Production**: Your deployed server URL

### Port Assignments
- **Rust**: 8080
- **Python**: 8000  
- **Node.js**: 8000
- **Bash**: 8080

## 📋 API Endpoints

### 1. Root Greeting Endpoint

**Endpoint**: `GET /`  
**Alternative**: `GET /greet`

**Parameters**:
- `name` (string, optional) - Name to greet (default: "World")
- `language` (string, optional) - Language code (default: "en")

**Example Request**:
```bash
curl "http://localhost:8000/greet?name=User&language=es"
```

**Example Response**:
```json
{
  "message": "¡Hola, User!",
  "name": "User",
  "language": "es",
  "timestamp": "2024-01-01T00:00:00Z",
  "server": "Python/FastAPI"
}
```

### 2. Health Check

**Endpoint**: `GET /health`

**Example Request**:
```bash
curl "http://localhost:8000/health"
```

**Example Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": "N/A",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 3. Available Languages

**Endpoint**: `GET /languages`

**Example Request**:
```bash
curl "http://localhost:8000/languages"
```

**Example Response**:
```json
["en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]
```

### 4. Language Information

**Endpoint**: `GET /languages/{language}`

**Example Request**:
```bash
curl "http://localhost:8000/languages/es"
```

**Example Response**:
```json
{
  "language": "es",
  "template": "¡Hola, {}!",
  "example": "¡Hola, World!",
  "supported": true
}
```

## 🌍 Supported Languages

| Code | Language | Greeting Template |
|------|----------|-------------------|
| en   | English  | Hello, {}! |
| es   | Spanish  | ¡Hola, {}! |
| fr   | French   | Bonjour, {}! |
| de   | German   | Hallo, {}! |
| it   | Italian  | Ciao, {}! |
| pt   | Portuguese | Olá, {}! |
| ru   | Russian  | Привет, {}! |
| ja   | Japanese | こんにちは、{}！ |
| zh   | Chinese  | 你好，{}！ |

## 🔧 Language-Specific Documentation

### 🦀 Rust (Actix Web)
- **Port**: 8080
- **Features**: Type-safe, high-performance, async
- **Source**: [server.rs](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/src/server.rs)

### 🐍 Python (FastAPI)
- **Port**: 8000
- **Features**: Auto-generated OpenAPI docs, type hints
- **Interactive Docs**: `http://localhost:8000/docs`
- **Source**: [server.py](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/server.py)

### 🟢 Node.js (Express)
- **Port**: 8000
- **Features**: Middleware support, JSON responses
- **API Docs**: `http://localhost:8000/api-docs`
- **Source**: [server.js](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/server.js)

### 🐚 Bash (Netcat)
- **Port**: 8080
- **Features**: Lightweight, no dependencies
- **Source**: [server.sh](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/server.sh)

## 🧪 Testing the API

### Quick Test Commands

```bash
# Test all implementations
curl http://localhost:8080/greet?name=Rust&language=es    # Rust
curl http://localhost:8000/greet?name=Python&language=fr  # Python
curl http://localhost:8000/greet?name=Node&language=de    # Node.js
curl http://localhost:8080/greet?name=Bash&language=it    # Bash
```

### Health Checks

```bash
# Check all servers are running
curl http://localhost:8080/health  # Rust/Bash
curl http://localhost:8000/health  # Python/Node.js
```

## 📊 Response Schema

All endpoints return JSON responses with consistent structure:

```typescript
interface GreetingResponse {
  message: string;      // The greeting message
  name: string;         // Name that was greeted
  language: string;     // Language code used
  timestamp: string;    // ISO 8601 timestamp
  server: string;       // Server implementation
}

interface HealthResponse {
  status: string;       // "healthy" or error
  version: string;      // API version
  uptime: string;       // Server uptime
  timestamp: string;    // Current timestamp
}

interface LanguageInfo {
  language: string;     // Language code
  template: string;     // Greeting template
  example: string;      // Example greeting
  supported: boolean;   // Always true for valid languages
}
```

## 🚀 Getting Started

1. **Choose a language implementation**
2. **Navigate to the example directory**:
   ```bash
   cd examples/[language]
   ```
3. **Install dependencies** (if needed)
4. **Start the server**:
   - Rust: `cargo run --bin server`
   - Python: `python server.py`
   - Node.js: `npm start`
   - Bash: `./server.sh`
5. **Test the API** using the examples above

## 🔗 Related Documentation

- [Language Examples](/examples/)
- [Getting Started Guide](/getting-started/)
- [Workflows and CI/CD](/workflows/)
- [GitHub Repository](https://github.com/alistairhendersoninfo/git-flow-boilerplate)