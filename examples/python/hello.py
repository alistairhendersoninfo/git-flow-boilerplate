#!/usr/bin/env python3
"""
Hello World application in Python
Demonstrates CLI interface, JSON output, and internationalization
"""

import json
import click
from datetime import datetime
from typing import Dict, Optional


def get_greetings() -> Dict[str, str]:
    """Get available greetings in different languages"""
    return {
        "en": "Hello, {}!",
        "es": "¡Hola, {}!",
        "fr": "Bonjour, {}!",
        "de": "Hallo, {}!",
        "it": "Ciao, {}!",
        "pt": "Olá, {}!",
        "ru": "Привет, {}!",
        "ja": "こんにちは、{}！",
        "zh": "你好，{}！",
    }


class GreetingService:
    """Service class for handling greetings"""
    
    def __init__(self):
        self.greetings = get_greetings()
    
    def greet(self, name: str, language: str = "en") -> str:
        """Generate a greeting message"""
        template = self.greetings.get(language, self.greetings["en"])
        return template.format(name)
    
    def get_available_languages(self) -> list:
        """Get list of available languages"""
        return list(self.greetings.keys())
    
    def create_greeting_data(self, name: str, language: str = "en") -> dict:
        """Create structured greeting data"""
        return {
            "message": self.greet(name, language),
            "name": name,
            "language": language,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "server": "Python/FastAPI"
        }


@click.command()
@click.option("--name", "-n", default="World", help="Name to greet")
@click.option("--format", "-f", default="text", 
              type=click.Choice(["text", "json"]), help="Output format")
@click.option("--language", "-l", default="en", help="Language for greeting")
@click.option("--list-languages", is_flag=True, help="List available languages")
def main(name: str, format: str, language: str, list_languages: bool):
    """Hello World CLI application"""
    
    service = GreetingService()
    
    if list_languages:
        languages = service.get_available_languages()
        if format == "json":
            click.echo(json.dumps({"languages": languages}, indent=2))
        else:
            click.echo("Available languages:")
            for lang in languages:
                click.echo(f"  {lang}")
        return
    
    if format == "json":
        data = service.create_greeting_data(name, language)
        click.echo(json.dumps(data, indent=2))
    else:
        message = service.greet(name, language)
        click.echo(message)


if __name__ == "__main__":
    main()