#!/usr/bin/env node
/**
 * Hello World CLI application in Node.js
 * Demonstrates command-line interface, JSON output, and internationalization
 * @author Development Team
 * @version 1.0.0
 */

const { Command } = require('commander');
const chalk = require('chalk');

/**
 * Available greetings in different languages
 * @type {Object<string, string>}
 */
const GREETINGS = {
  en: 'Hello, {}!',
  es: '¡Hola, {}!',
  fr: 'Bonjour, {}!',
  de: 'Hallo, {}!',
  it: 'Ciao, {}!',
  pt: 'Olá, {}!',
  ru: 'Привет, {}!',
  ja: 'こんにちは、{}！',
  zh: '你好，{}！'
};

/**
 * Service class for handling greetings
 */
class GreetingService {
  constructor() {
    this.greetings = GREETINGS;
  }

  /**
   * Generate a greeting message
   * @param {string} name - Name to greet
   * @param {string} language - Language code
   * @returns {string} Greeting message
   */
  greet(name, language = 'en') {
    const template = this.greetings[language] || this.greetings.en;
    return template.replace('{}', name);
  }

  /**
   * Get list of available languages
   * @returns {string[]} Array of language codes
   */
  getAvailableLanguages() {
    return Object.keys(this.greetings);
  }

  /**
   * Create structured greeting data
   * @param {string} name - Name to greet
   * @param {string} language - Language code
   * @returns {Object} Greeting data object
   */
  createGreetingData(name, language = 'en') {
    return {
      message: this.greet(name, language),
      name,
      language,
      timestamp: new Date().toISOString(),
      server: 'Node.js/Express'
    };
  }

  /**
   * Validate if a language is supported
   * @param {string} language - Language code to validate
   * @returns {boolean} True if language is supported
   */
  isLanguageSupported(language) {
    return language in this.greetings;
  }
}

/**
 * Main CLI function
 */
function main() {
  const program = new Command();
  const service = new GreetingService();

  program
    .name('hello')
    .description('Hello World CLI application in Node.js')
    .version('1.0.0');

  program
    .option('-n, --name <name>', 'name to greet', 'World')
    .option('-f, --format <format>', 'output format (text, json)', 'text')
    .option('-l, --language <language>', 'language for greeting', 'en')
    .option('--list-languages', 'list available languages')
    .action((options) => {
      try {
        // Handle list languages
        if (options.listLanguages) {
          const languages = service.getAvailableLanguages();
          
          if (options.format === 'json') {
            console.log(JSON.stringify({ languages }, null, 2));
          } else {
            console.log(chalk.blue('Available languages:'));
            languages.sort().forEach(lang => {
              console.log(`  ${lang}`);
            });
          }
          return;
        }

        // Validate format
        if (!['text', 'json'].includes(options.format)) {
          console.error(chalk.red(`Error: Invalid format '${options.format}'. Use 'text' or 'json'`));
          process.exit(1);
        }

        // Validate language (warn but continue with English if invalid)
        if (!service.isLanguageSupported(options.language)) {
          console.warn(chalk.yellow(`Warning: Language '${options.language}' not supported, using English`));
          options.language = 'en';
        }

        // Generate and output greeting
        if (options.format === 'json') {
          const data = service.createGreetingData(options.name, options.language);
          console.log(JSON.stringify(data, null, 2));
        } else {
          const message = service.greet(options.name, options.language);
          console.log(chalk.green(message));
        }

      } catch (error) {
        console.error(chalk.red('Error:'), error.message);
        process.exit(1);
      }
    });

  program.parse();
}

// Export for testing
module.exports = {
  GreetingService,
  GREETINGS
};

// Run main function if script is executed directly
if (require.main === module) {
  main();
}