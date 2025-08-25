/**
 * Test suite for Hello World Node.js application
 * @author Development Team
 */

const { GreetingService, GREETINGS } = require('./hello');
const request = require('supertest');
const app = require('./server');

describe('GreetingService', () => {
  let service;

  beforeEach(() => {
    service = new GreetingService();
  });

  describe('greet', () => {
    test('should return default English greeting', () => {
      const result = service.greet('Node.js');
      expect(result).toBe('Hello, Node.js!');
    });

    test('should return Spanish greeting', () => {
      const result = service.greet('Node.js', 'es');
      expect(result).toBe('¡Hola, Node.js!');
    });

    test('should return French greeting', () => {
      const result = service.greet('Node.js', 'fr');
      expect(result).toBe('Bonjour, Node.js!');
    });

    test('should fallback to English for invalid language', () => {
      const result = service.greet('Node.js', 'invalid');
      expect(result).toBe('Hello, Node.js!');
    });
  });

  describe('getAvailableLanguages', () => {
    test('should return array of language codes', () => {
      const languages = service.getAvailableLanguages();
      expect(Array.isArray(languages)).toBe(true);
      expect(languages).toContain('en');
      expect(languages).toContain('es');
      expect(languages.length).toBeGreaterThan(0);
    });
  });

  describe('createGreetingData', () => {
    test('should return structured greeting data', () => {
      const data = service.createGreetingData('Node.js', 'en');
      
      expect(data).toHaveProperty('message');
      expect(data).toHaveProperty('name');
      expect(data).toHaveProperty('language');
      expect(data).toHaveProperty('timestamp');
      expect(data).toHaveProperty('server');
      
      expect(data.message).toBe('Hello, Node.js!');
      expect(data.name).toBe('Node.js');
      expect(data.language).toBe('en');
      expect(data.server).toBe('Node.js/Express');
      expect(typeof data.timestamp).toBe('string');
    });

    test('should handle different languages', () => {
      const data = service.createGreetingData('Node.js', 'es');
      expect(data.message).toBe('¡Hola, Node.js!');
      expect(data.language).toBe('es');
    });
  });

  describe('isLanguageSupported', () => {
    test('should return true for supported languages', () => {
      expect(service.isLanguageSupported('en')).toBe(true);
      expect(service.isLanguageSupported('es')).toBe(true);
      expect(service.isLanguageSupported('fr')).toBe(true);
    });

    test('should return false for unsupported languages', () => {
      expect(service.isLanguageSupported('invalid')).toBe(false);
      expect(service.isLanguageSupported('xyz')).toBe(false);
    });
  });
});

describe('GREETINGS constant', () => {
  test('should contain expected languages', () => {
    const expectedLanguages = ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'zh'];
    
    expectedLanguages.forEach(lang => {
      expect(GREETINGS).toHaveProperty(lang);
      expect(typeof GREETINGS[lang]).toBe('string');
      expect(GREETINGS[lang]).toContain('{}');
    });
  });

  test('should have English greeting', () => {
    expect(GREETINGS.en).toBe('Hello, {}!');
  });

  test('should have Spanish greeting', () => {
    expect(GREETINGS.es).toBe('¡Hola, {}!');
  });
});

describe('Express Server API', () => {
  describe('GET /', () => {
    test('should return default greeting', async () => {
      const response = await request(app).get('/');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('language');
      expect(response.body.message).toBe('Hello, World!');
      expect(response.body.name).toBe('World');
      expect(response.body.language).toBe('en');
    });

    test('should handle custom name and language', async () => {
      const response = await request(app)
        .get('/')
        .query({ name: 'Node.js', language: 'es' });
      
      expect(response.status).toBe(200);
      expect(response.body.message).toBe('¡Hola, Node.js!');
      expect(response.body.name).toBe('Node.js');
      expect(response.body.language).toBe('es');
    });
  });

  describe('GET /greet', () => {
    test('should work same as root endpoint', async () => {
      const response = await request(app)
        .get('/greet')
        .query({ name: 'Test', language: 'fr' });
      
      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Bonjour, Test!');
    });
  });

  describe('GET /health', () => {
    test('should return health status', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body.status).toBe('healthy');
    });
  });

  describe('GET /languages', () => {
    test('should return available languages', async () => {
      const response = await request(app).get('/languages');
      
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toContain('en');
      expect(response.body).toContain('es');
    });
  });

  describe('GET /languages/:language', () => {
    test('should return language information', async () => {
      const response = await request(app).get('/languages/en');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('language');
      expect(response.body).toHaveProperty('template');
      expect(response.body).toHaveProperty('example');
      expect(response.body.language).toBe('en');
      expect(response.body.template).toBe('Hello, {}!');
      expect(response.body.example).toBe('Hello, World!');
    });

    test('should return 404 for unsupported language', async () => {
      const response = await request(app).get('/languages/invalid');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toBe('Language Not Found');
    });
  });

  describe('GET /api-docs', () => {
    test('should return API documentation', async () => {
      const response = await request(app).get('/api-docs');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('title');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('endpoints');
      expect(Array.isArray(response.body.endpoints)).toBe(true);
    });
  });

  describe('404 handler', () => {
    test('should return 404 for unknown endpoints', async () => {
      const response = await request(app).get('/unknown');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toBe('Not Found');
    });
  });
});