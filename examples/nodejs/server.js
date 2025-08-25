#!/usr/bin/env node
/**
 * Hello World Express server
 * Provides REST API endpoints for greetings with multi-language support
 * @author Development Team
 * @version 1.0.0
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { GreetingService } = require('./hello');

// Initialize Express app
const app = express();
const port = process.env.PORT || 8000;
const host = process.env.HOST || '127.0.0.1';

// Initialize greeting service
const greetingService = new GreetingService();

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(morgan('combined')); // Logging
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

/**
 * Root endpoint - greeting with query parameters
 * @route GET /
 * @param {string} [name=World] - Name to greet
 * @param {string} [language=en] - Language code
 * @returns {Object} Greeting response
 */
app.get('/', (req, res) => {
  try {
    const { name = 'World', language = 'en' } = req.query;
    const data = greetingService.createGreetingData(name, language);
    res.json(data);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * Greeting endpoint - same as root
 * @route GET /greet
 * @param {string} [name=World] - Name to greet
 * @param {string} [language=en] - Language code
 * @returns {Object} Greeting response
 */
app.get('/greet', (req, res) => {
  try {
    const { name = 'World', language = 'en' } = req.query;
    const data = greetingService.createGreetingData(name, language);
    res.json(data);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * Health check endpoint
 * @route GET /health
 * @returns {Object} Health status
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    version: '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    node_version: process.version,
    memory: process.memoryUsage()
  });
});

/**
 * Get available languages
 * @route GET /languages
 * @returns {string[]} Array of language codes
 */
app.get('/languages', (req, res) => {
  try {
    const languages = greetingService.getAvailableLanguages();
    res.json(languages);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * Get information about a specific language
 * @route GET /languages/:language
 * @param {string} language - Language code
 * @returns {Object} Language information
 */
app.get('/languages/:language', (req, res) => {
  try {
    const { language } = req.params;
    
    if (!greetingService.isLanguageSupported(language)) {
      return res.status(404).json({
        error: 'Language Not Found',
        message: `Language '${language}' is not supported`
      });
    }
    
    const template = greetingService.greetings[language];
    const example = greetingService.greet('World', language);
    
    res.json({
      language,
      template,
      example,
      supported: true
    });
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * API documentation endpoint
 * @route GET /api-docs
 * @returns {Object} API documentation
 */
app.get('/api-docs', (req, res) => {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  
  res.json({
    title: 'Hello World API',
    version: '1.0.0',
    description: 'A simple greeting API with multi-language support',
    baseUrl,
    endpoints: [
      {
        method: 'GET',
        path: '/',
        description: 'Generate a greeting',
        parameters: [
          { name: 'name', type: 'string', default: 'World', description: 'Name to greet' },
          { name: 'language', type: 'string', default: 'en', description: 'Language code' }
        ]
      },
      {
        method: 'GET',
        path: '/greet',
        description: 'Generate a greeting (same as /)',
        parameters: [
          { name: 'name', type: 'string', default: 'World', description: 'Name to greet' },
          { name: 'language', type: 'string', default: 'en', description: 'Language code' }
        ]
      },
      {
        method: 'GET',
        path: '/health',
        description: 'Health check endpoint',
        parameters: []
      },
      {
        method: 'GET',
        path: '/languages',
        description: 'Get available languages',
        parameters: []
      },
      {
        method: 'GET',
        path: '/languages/:language',
        description: 'Get information about a specific language',
        parameters: [
          { name: 'language', type: 'string', description: 'Language code' }
        ]
      }
    ],
    examples: [
      `${baseUrl}/`,
      `${baseUrl}/greet?name=Node.js&language=es`,
      `${baseUrl}/health`,
      `${baseUrl}/languages`,
      `${baseUrl}/languages/fr`
    ]
  });
});

/**
 * 404 handler
 */
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: 'The requested endpoint does not exist',
    available_endpoints: [
      '/',
      '/greet',
      '/health',
      '/languages',
      '/languages/:language',
      '/api-docs'
    ]
  });
});

/**
 * Error handler
 */
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    error: 'Internal Server Error',
    message: error.message
  });
});

/**
 * Start server
 */
if (require.main === module) {
  app.listen(port, host, () => {
    console.log(`🚀 Node.js Hello World server running on http://${host}:${port}`);
    console.log(`📚 API documentation: http://${host}:${port}/api-docs`);
    console.log(`❤️  Health check: http://${host}:${port}/health`);
    console.log('');
    console.log('Available endpoints:');
    console.log(`  GET /         - Greeting endpoint`);
    console.log(`  GET /greet    - Greeting endpoint`);
    console.log(`  GET /health   - Health check`);
    console.log(`  GET /languages - Available languages`);
    console.log('');
    console.log('Press Ctrl+C to stop the server');
  });
}

module.exports = app;