use clap::Parser;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Hello World application in Rust
#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Name to greet
    #[arg(short, long, default_value = "World")]
    name: String,
    
    /// Output format (text, json)
    #[arg(short, long, default_value = "text")]
    format: String,
    
    /// Language for greeting
    #[arg(short, long, default_value = "en")]
    language: String,
}

#[derive(Serialize, Deserialize)]
struct Greeting {
    message: String,
    name: String,
    language: String,
    timestamp: String,
}

fn main() {
    let args = Args::parse();
    
    let greetings = get_greetings();
    let greeting_template = greetings.get(&args.language)
        .unwrap_or(&"Hello, {}!".to_string());
    
    let message = greeting_template.replace("{}", &args.name);
    
    match args.format.as_str() {
        "json" => {
            let greeting = Greeting {
                message: message.clone(),
                name: args.name,
                language: args.language,
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs()
                    .to_string(),
            };
            println!("{}", serde_json::to_string_pretty(&greeting).unwrap());
        }
        _ => {
            println!("{}", message);
        }
    }
}

/// Get available greetings in different languages
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_greetings() {
        let greetings = get_greetings();
        assert!(greetings.contains_key("en"));
        assert!(greetings.contains_key("es"));
        assert_eq!(greetings.get("en").unwrap(), "Hello, {}!");
    }

    #[test]
    fn test_greeting_replacement() {
        let greetings = get_greetings();
        let template = greetings.get("en").unwrap();
        let message = template.replace("{}", "Rust");
        assert_eq!(message, "Hello, Rust!");
    }
}