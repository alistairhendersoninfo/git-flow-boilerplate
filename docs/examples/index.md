---
layout: page
title: Examples
permalink: /examples/
---

# Code Examples

Comprehensive examples demonstrating the Universal Git Flow Boilerplate across multiple programming languages.

## 🚀 Quick Demo

Each language implementation provides the same functionality with consistent APIs:

### CLI Usage
```bash
# All languages support the same interface
./hello --name "World" --language "es" --format json
```

### HTTP API
```bash
# Consistent REST API across all languages
curl "http://localhost:8080/greet?name=User&language=fr"
```

## 🦀 Rust Examples

### CLI Application
**File**: [examples/rust/src/main.rs](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/src/main.rs)

```rust
use clap::Parser;
use serde::{Deserialize, Serialize};

#[derive(Parser)]
#[command(author, version, about)]
struct Args {
    #[arg(short, long, default_value = "World")]
    name: String,
    
    #[arg(short, long, default_value = "text")]
    format: String,
    
    #[arg(short, long, default_value = "en")]
    language: String,
}

fn main() {
    let args = Args::parse();
    let message = generate_greeting(&args.name, &args.language);
    
    if args.format == "json" {
        println!("{}", serde_json::to_string_pretty(&greeting_data).unwrap());
    } else {
        println!("{}", message);
    }
}
```

### HTTP Server
**File**: [examples/rust/src/server.rs](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/rust/src/server.rs)

```rust
use actix_web::{web, App, HttpResponse, HttpServer, Result};

async fn greet(query: web::Query<GreetingRequest>) -> Result<HttpResponse> {
    let name = query.name.as_deref().unwrap_or("World");
    let language = query.language.as_deref().unwrap_or("en");
    
    let response = GreetingResponse {
        message: generate_greeting(name, language),
        name: name.to_string(),
        language: language.to_string(),
        timestamp: get_timestamp(),
        server: "Rust/Actix-Web".to_string(),
    };
    
    Ok(HttpResponse::Ok().json(response))
}
```

**Run the examples**:
```bash
cd examples/rust
cargo run --bin hello -- --name "Rust" --language "es"
cargo run --bin server
```

## 🐍 Python Examples

### CLI Application
**File**: [examples/python/hello.py](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/hello.py)

```python
import click
import json
from datetime import datetime

@click.command()
@click.option("--name", "-n", default="World", help="Name to greet")
@click.option("--format", "-f", default="text", help="Output format")
@click.option("--language", "-l", default="en", help="Language code")
def main(name: str, format: str, language: str):
    """Hello World CLI application"""
    
    service = GreetingService()
    
    if format == "json":
        data = service.create_greeting_data(name, language)
        click.echo(json.dumps(data, indent=2))
    else:
        message = service.greet(name, language)
        click.echo(message)
```

### FastAPI Server
**File**: [examples/python/server.py](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/python/server.py)

```python
from fastapi import FastAPI, Query
from pydantic import BaseModel

app = FastAPI(title="Hello World API")

@app.get("/greet")
async def greet(
    name: str = Query("World", description="Name to greet"),
    language: str = Query("en", description="Language code")
):
    """Generate a greeting message"""
    data = greeting_service.create_greeting_data(name, language)
    return data
```

**Run the examples**:
```bash
cd examples/python
pip install -r requirements.txt
python hello.py --name "Python" --format json
python server.py
```

## 🟢 Node.js Examples

### CLI Application
**File**: [examples/nodejs/hello.js](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/hello.js)

```javascript
const { Command } = require('commander');
const chalk = require('chalk');

const program = new Command();

program
  .option('-n, --name <name>', 'name to greet', 'World')
  .option('-f, --format <format>', 'output format', 'text')
  .option('-l, --language <language>', 'language code', 'en')
  .action((options) => {
    const service = new GreetingService();
    
    if (options.format === 'json') {
      const data = service.createGreetingData(options.name, options.language);
      console.log(JSON.stringify(data, null, 2));
    } else {
      const message = service.greet(options.name, options.language);
      console.log(chalk.green(message));
    }
  });
```

### Express Server
**File**: [examples/nodejs/server.js](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/nodejs/server.js)

```javascript
const express = require('express');
const { GreetingService } = require('./hello');

const app = express();
const greetingService = new GreetingService();

app.get('/greet', (req, res) => {
  const { name = 'World', language = 'en' } = req.query;
  const data = greetingService.createGreetingData(name, language);
  res.json(data);
});

app.listen(8000, () => {
  console.log('🚀 Node.js server running on http://localhost:8000');
});
```

**Run the examples**:
```bash
cd examples/nodejs
npm install
node hello.js --name "Node.js" --language "fr"
npm start
```

## 🐚 Bash Examples

### CLI Application
**File**: [examples/bash/hello.sh](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/hello.sh)

```bash
#!/bin/bash
# Hello World application in Bash

# Default values
NAME="World"
FORMAT="text"
LANGUAGE="en"

# Greeting templates
declare -A GREETINGS=(
    ["en"]="Hello, {}!"
    ["es"]="¡Hola, {}!"
    ["fr"]="Bonjour, {}!"
    ["de"]="Hallo, {}!"
)

# Generate greeting
generate_greeting() {
    local name="$1"
    local language="$2"
    local template="${GREETINGS[$language]:-${GREETINGS[en]}}"
    echo "${template//\{\}/$name}"
}

# Output greeting
if [[ "$FORMAT" == "json" ]]; then
    cat << EOF
{
  "message": "$(generate_greeting "$NAME" "$LANGUAGE")",
  "name": "$NAME",
  "language": "$LANGUAGE",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "server": "Bash/Shell"
}
EOF
else
    echo "$(generate_greeting "$NAME" "$LANGUAGE")"
fi
```

### HTTP Server
**File**: [examples/bash/server.sh](https://github.com/alistairhendersoninfo/git-flow-boilerplate/blob/main/examples/bash/server.sh)

```bash
#!/bin/bash
# Simple HTTP server using netcat

handle_request() {
    local request_line
    read -r request_line
    
    # Parse query parameters
    local query=$(echo "$request_line" | cut -d'?' -f2)
    local name="World"
    local language="en"
    
    # Generate JSON response
    local json_response=$(cat << EOF
{
  "message": "$(generate_greeting "$name" "$language")",
  "name": "$name",
  "language": "$language",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "server": "Bash/Netcat"
}
EOF
)
    
    # Send HTTP response
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n$json_response"
}
```

**Run the examples**:
```bash
cd examples/bash
./hello.sh --name "Bash" --language "de"
./server.sh --port 8080
```

## 🧪 Testing Examples

Each language includes comprehensive test suites:

### Rust Testing
```bash
cd examples/rust
cargo test --verbose
```

### Python Testing
```bash
cd examples/python
pytest --cov=hello --cov=server
```

### Node.js Testing
```bash
cd examples/nodejs
npm test
```

### Bash Testing
```bash
cd examples/bash
./test_hello.sh
```

## 🌍 Multi-Language Support

All examples support these languages:

| Code | Language | Example Greeting |
|------|----------|------------------|
| en   | English  | Hello, World! |
| es   | Spanish  | ¡Hola, World! |
| fr   | French   | Bonjour, World! |
| de   | German   | Hallo, World! |
| it   | Italian  | Ciao, World! |
| pt   | Portuguese | Olá, World! |
| ru   | Russian  | Привет, World! |
| ja   | Japanese | こんにちは、World！ |
| zh   | Chinese  | 你好，World！ |

## 📊 API Consistency

All server implementations provide the same endpoints:

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Root greeting endpoint |
| `/greet` | GET | Same as root |
| `/health` | GET | Health check |
| `/languages` | GET | Available languages |
| `/languages/{code}` | GET | Language details |

### Response Format

```json
{
  "message": "Hello, World!",
  "name": "World",
  "language": "en",
  "timestamp": "2024-01-01T00:00:00Z",
  "server": "Language/Framework"
}
```

## 🚀 Getting Started

1. **Choose a language** from the examples above
2. **Navigate to the directory**: `cd examples/[language]`
3. **Install dependencies** (if needed)
4. **Run the CLI example**: Follow the language-specific instructions
5. **Start the server**: Run the HTTP server example
6. **Test the API**: Use curl or browser to test endpoints

## 🔗 Related Resources

- [Language Documentation](/languages/)
- [Getting Started Guide](/getting-started/)
- [API Documentation](/api/)
- [Workflows and CI/CD](/workflows/)
- [GitHub Repository](https://github.com/alistairhendersoninfo/git-flow-boilerplate)