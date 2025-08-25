use actix_web::{web, App, HttpResponse, HttpServer, Result, middleware::Logger};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Serialize, Deserialize)]
struct GreetingRequest {
    name: Option<String>,
    language: Option<String>,
}

#[derive(Serialize)]
struct GreetingResponse {
    message: String,
    name: String,
    language: String,
    timestamp: String,
    server: String,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    version: String,
    uptime: String,
}

async fn greet(query: web::Query<GreetingRequest>) -> Result<HttpResponse> {
    let name = query.name.as_deref().unwrap_or("World");
    let language = query.language.as_deref().unwrap_or("en");
    
    let greetings = get_greetings();
    let greeting_template = greetings.get(language)
        .unwrap_or(&"Hello, {}!".to_string());
    
    let message = greeting_template.replace("{}", name);
    
    let response = GreetingResponse {
        message,
        name: name.to_string(),
        language: language.to_string(),
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs()
            .to_string(),
        server: "Rust/Actix-Web".to_string(),
    };
    
    Ok(HttpResponse::Ok().json(response))
}

async fn health() -> Result<HttpResponse> {
    let response = HealthResponse {
        status: "healthy".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        uptime: "N/A".to_string(), // In a real app, you'd track this
    };
    
    Ok(HttpResponse::Ok().json(response))
}

async fn languages() -> Result<HttpResponse> {
    let greetings = get_greetings();
    let languages: Vec<&String> = greetings.keys().collect();
    
    Ok(HttpResponse::Ok().json(languages))
}

fn get_greetings() -> HashMap<String, String> {
    let mut greetings = HashMap::new();
    greetings.insert("en".to_string(), "Hello, {}!".to_string());
    greetings.insert("es".to_string(), "¡Hola, {}!".to_string());
    greetings.insert("fr".to_string(), "Bonjour, {}!".to_string());
    greetings.insert("de".to_string(), "Hallo, {}!".to_string());
    greetings.insert("it".to_string(), "Ciao, {}!".to_string());
    greetings.insert("pt".to_string(), "Olá, {}!".to_string());
    greetings.insert("ru".to_string(), "Привет, {}!".to_string());
    greetings.insert("ja".to_string(), "こんにちは、{}！".to_string());
    greetings.insert("zh".to_string(), "你好，{}！".to_string());
    greetings
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();
    
    println!("Starting Rust Hello World server on http://localhost:8080");
    
    HttpServer::new(|| {
        App::new()
            .wrap(Logger::default())
            .route("/", web::get().to(greet))
            .route("/greet", web::get().to(greet))
            .route("/health", web::get().to(health))
            .route("/languages", web::get().to(languages))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}