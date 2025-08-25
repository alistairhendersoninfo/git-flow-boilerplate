#!/usr/bin/env python3
"""
Hello World FastAPI server
Provides REST API endpoints for greetings
"""

from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uvicorn

from hello import GreetingService


app = FastAPI(
    title="Hello World API",
    description="A simple greeting API with multi-language support",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Initialize greeting service
greeting_service = GreetingService()


class GreetingResponse(BaseModel):
    """Response model for greeting endpoints"""
    message: str
    name: str
    language: str
    timestamp: str
    server: str


class HealthResponse(BaseModel):
    """Response model for health check"""
    status: str
    version: str
    uptime: str


@app.get("/", response_model=GreetingResponse)
@app.get("/greet", response_model=GreetingResponse)
async def greet(
    name: Optional[str] = Query("World", description="Name to greet"),
    language: Optional[str] = Query("en", description="Language code")
):
    """
    Generate a greeting message
    
    - **name**: The name to greet (default: World)
    - **language**: Language code for the greeting (default: en)
    """
    data = greeting_service.create_greeting_data(name, language)
    return GreetingResponse(**data)


@app.get("/health", response_model=HealthResponse)
async def health():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        uptime="N/A"  # In a real app, you'd track this
    )


@app.get("/languages", response_model=List[str])
async def get_languages():
    """Get available languages"""
    return greeting_service.get_available_languages()


@app.get("/languages/{language}")
async def get_language_info(language: str):
    """Get information about a specific language"""
    greetings = greeting_service.greetings
    if language not in greetings:
        return {"error": f"Language '{language}' not supported"}
    
    return {
        "language": language,
        "template": greetings[language],
        "example": greetings[language].format("World")
    }


if __name__ == "__main__":
    print("Starting Python Hello World server on http://localhost:8000")
    uvicorn.run(
        "server:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
        log_level="info"
    )