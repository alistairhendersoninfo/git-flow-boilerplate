#!/usr/bin/env python3
"""
Tests for the Hello World Python application
"""

import pytest
import json
from hello import GreetingService, get_greetings


class TestGreetingService:
    """Test cases for GreetingService"""
    
    def setup_method(self):
        """Set up test fixtures"""
        self.service = GreetingService()
    
    def test_greet_default_language(self):
        """Test greeting with default language (English)"""
        result = self.service.greet("Python")
        assert result == "Hello, Python!"
    
    def test_greet_spanish(self):
        """Test greeting in Spanish"""
        result = self.service.greet("Python", "es")
        assert result == "¡Hola, Python!"
    
    def test_greet_invalid_language(self):
        """Test greeting with invalid language falls back to English"""
        result = self.service.greet("Python", "invalid")
        assert result == "Hello, Python!"
    
    def test_get_available_languages(self):
        """Test getting available languages"""
        languages = self.service.get_available_languages()
        assert isinstance(languages, list)
        assert "en" in languages
        assert "es" in languages
        assert len(languages) > 0
    
    def test_create_greeting_data(self):
        """Test creating structured greeting data"""
        data = self.service.create_greeting_data("Python", "en")
        
        assert "message" in data
        assert "name" in data
        assert "language" in data
        assert "timestamp" in data
        assert "server" in data
        
        assert data["message"] == "Hello, Python!"
        assert data["name"] == "Python"
        assert data["language"] == "en"
        assert data["server"] == "Python/FastAPI"


class TestGetGreetings:
    """Test cases for get_greetings function"""
    
    def test_get_greetings_returns_dict(self):
        """Test that get_greetings returns a dictionary"""
        greetings = get_greetings()
        assert isinstance(greetings, dict)
    
    def test_get_greetings_has_english(self):
        """Test that English greeting is available"""
        greetings = get_greetings()
        assert "en" in greetings
        assert greetings["en"] == "Hello, {}!"
    
    def test_get_greetings_has_multiple_languages(self):
        """Test that multiple languages are available"""
        greetings = get_greetings()
        expected_languages = ["en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]
        
        for lang in expected_languages:
            assert lang in greetings
            assert "{}" in greetings[lang]  # Template should have placeholder


if __name__ == "__main__":
    pytest.main([__file__, "-v"])