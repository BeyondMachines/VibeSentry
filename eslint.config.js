import js from '@eslint/js';
import security from 'eslint-plugin-security';
import noUnsanitized from 'eslint-plugin-no-unsanitized';
import importPlugin from 'eslint-plugin-import';
import nodePlugin from 'eslint-plugin-n';
import globals from 'globals';

export default [
  // Base recommended rules
  js.configs.recommended,
  
  // Main security configuration
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.es2022,
      },
    },
    
    plugins: {
      security,
      'no-unsanitized': noUnsanitized,
      import: importPlugin,
      n: nodePlugin,
    },
    
    rules: {
      // ===== CORE SECURITY RULES =====
      
      // Injection & Eval Protection
      'security/detect-object-injection': 'error',
      'security/detect-eval-with-expression': 'error',
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'no-script-url': 'error',
      
      // RegExp Security
      'security/detect-non-literal-regexp': 'error',
      'security/detect-unsafe-regex': 'error',
      'security/detect-bidi-characters': 'error',
      
      // Buffer & Crypto Security
      'security/detect-buffer-noassert': 'error',
      'security/detect-new-buffer': 'error',
      'security/detect-pseudoRandomBytes': 'error',
      
      // File System Security
      'security/detect-non-literal-fs-filename': 'warn',
      'security/detect-non-literal-require': 'warn',
      
      // Process & Child Process Security
      'security/detect-child-process': 'warn',
      'security/detect-disable-mustache-escape': 'error',
      'security/detect-possible-timing-attacks': 'error',
      
      // XSS & DOM Security
      'no-unsanitized/method': 'error',
      'no-unsanitized/property': 'error',
      
      // ===== ADDITIONAL SECURITY RULES =====
      
      // Dangerous Globals
      'no-global-assign': 'error',
      'no-implicit-globals': 'error',
      'no-extend-native': 'error',
      
      // Prototype Pollution Prevention
      'no-proto': 'error',
      'guard-for-in': 'error',
      
      // Input Validation
      'no-unreachable': 'error',
      'no-fallthrough': 'error',
      'default-case': 'error',
      'default-case-last': 'error',
      
      // Variable Safety
      'no-undef': 'error',
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-use-before-define': 'error',
      'no-redeclare': 'error',
      'no-shadow': 'error',
      
      // Function Safety
      'no-caller': 'error',
      'no-constructor-return': 'error',
      'no-new-wrappers': 'error',
      
      // Import Security
      'import/no-dynamic-require': 'error',
      'import/no-webpack-loader-syntax': 'error',
      'import/no-unresolved': 'error',
      'import/no-extraneous-dependencies': ['error', {
        devDependencies: ['**/*.test.js', '**/*.spec.js', '**/test/**', '**/tests/**']
      }],
      
      // Node.js Security
      'n/no-deprecated-api': 'error',
      'n/no-exports-assign': 'error',
      'n/no-unpublished-require': 'error',
      'n/no-process-exit': 'error',
      
      // ===== BEST PRACTICES FOR SECURITY =====
      
      // Code Quality (security-adjacent)
      'eqeqeq': ['error', 'always'],
      'no-eq-null': 'error',
      'no-lonely-if': 'error',
      'no-multi-assign': 'error',
      'no-nested-ternary': 'error',
      'no-unneeded-ternary': 'error',
      'prefer-const': 'error',
      'no-var': 'error',
      
      // Error Handling
      'no-empty': ['error', { allowEmptyCatch: false }],
      'no-empty-function': 'error',
      'require-await': 'error',
      'no-return-await': 'error',
      
      // Regex Safety
      'no-control-regex': 'error',
      'no-regex-spaces': 'error',
    },
    
    settings: {
      'import/resolver': {
        node: {
          extensions: ['.js', '.mjs', '.cjs']
        }
      }
    }
  },
  
  // Relaxed rules for test files
  {
    files: ['**/*.test.js', '**/*.spec.js', '**/test/**', '**/tests/**'],
    rules: {
      'security/detect-non-literal-fs-filename': 'off',
      'security/detect-child-process': 'off',
      'no-unused-vars': 'off'
    }
  },
  
  // Relaxed rules for configuration files
  {
    files: ['*.config.js', '*.config.mjs', 'eslint.config.js'],
    rules: {
      'security/detect-non-literal-require': 'off',
      'import/no-dynamic-require': 'off'
    }
  }
];