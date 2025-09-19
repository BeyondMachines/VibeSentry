#!/bin/bash

# vibesentry/eslint.sh - ESLint Security Checker for Pre-commit Hooks
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print error with instructions
print_error_with_fix() {
    local error_type=$1
    local error_message=$2
    
    echo -e "${RED}${BOLD}❌ ESLint Security Check Failed${NC}"
    echo -e "${RED}Error: ${error_message}${NC}"
    echo ""
    
    case $error_type in
        "missing_deps")
            echo -e "${YELLOW}${BOLD}🔧 QUICK FIX:${NC}"
            echo -e "${BLUE}npm install --save-dev eslint @eslint/js eslint-plugin-security eslint-plugin-no-unsanitized eslint-plugin-import eslint-plugin-n globals${NC}"
            echo ""
            ;;
        "missing_config")
            echo -e "${YELLOW}${BOLD}🔧 QUICK FIX:${NC}"
            echo -e "Create ${BLUE}eslint.config.js${NC} with this content:"
            echo ""
            cat << 'EOF'
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
EOF
            echo ""
            echo -e "Also add ${BLUE}\"type\": \"module\"${NC} to your package.json"
            echo ""
            ;;
        "lint_failures")
            echo -e "${YELLOW}${BOLD}🔧 QUICK FIX:${NC}"
            echo -e "${BLUE}npm run lint -- --fix${NC}    ${YELLOW}# Auto-fix issues${NC}"
            echo -e "${BLUE}git add .${NC}                ${YELLOW}# Stage fixed files${NC}"
            echo -e "${BLUE}git commit${NC}               ${YELLOW}# Retry commit${NC}"
            echo ""
            echo -e "${YELLOW}Or manually fix the security issues shown above ☝️${NC}"
            echo ""
            ;;
    esac
    
    echo -e "${YELLOW}${BOLD}⚠️  BYPASS (NOT RECOMMENDED):${NC}"
    echo -e "${BLUE}git commit --no-verify${NC}       ${YELLOW}# Skip all pre-commit hooks${NC}"
    echo ""
}

# Main execution
echo -e "${BLUE}🔍 Running ESLint Security Check...${NC}"

# Get staged JavaScript/TypeScript files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|mjs|cjs|jsx|ts|tsx)$' || true)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}✅ No JavaScript/TypeScript files to check${NC}"
    exit 0
fi

echo -e "${BLUE}📝 Found files to check:${NC}"
echo "$STAGED_FILES" | sed 's/^/  • /'
echo ""

# Check if package.json exists
if [ ! -f "package.json" ]; then
    print_error_with_fix "missing_deps" "package.json not found"
    exit 1
fi

# Check if package.json has type: module
if ! grep -q '"type".*"module"' package.json; then
    echo -e "${YELLOW}⚠️  Add \"type\": \"module\" to package.json to avoid warnings${NC}"
fi

# Check if ESLint is installed
if ! command -v npx &> /dev/null; then
    print_error_with_fix "missing_deps" "npx not available (Node.js not installed?)"
    exit 1
fi

if ! npm list eslint &> /dev/null; then
    print_error_with_fix "missing_deps" "ESLint is not installed"
    exit 1
fi

# Check if eslint.config.js exists
if [ ! -f "eslint.config.js" ]; then
    print_error_with_fix "missing_config" "eslint.config.js not found"
    exit 1
fi

# Check if security plugins are installed
MISSING_PLUGINS=""
for plugin in "eslint-plugin-security" "eslint-plugin-no-unsanitized" "eslint-plugin-import" "eslint-plugin-n" "globals"; do
    if ! npm list $plugin &> /dev/null; then
        MISSING_PLUGINS="$MISSING_PLUGINS $plugin"
    fi
done

if [ ! -z "$MISSING_PLUGINS" ]; then
    print_error_with_fix "missing_deps" "Missing ESLint security plugins:$MISSING_PLUGINS"
    exit 1
fi

# Run ESLint on staged files
echo -e "${BLUE}🔒 Running security-focused ESLint...${NC}"

# Create temporary file with staged file list
TEMP_FILE=$(mktemp)
echo "$STAGED_FILES" | tr ' ' '\n' > "$TEMP_FILE"

# Run ESLint with staged files
if echo "$STAGED_FILES" | xargs npx eslint --no-ignore; then
    echo -e "${GREEN}✅ ESLint Security Check Passed!${NC}"
    echo -e "${GREEN}🔒 No security vulnerabilities detected in staged files${NC}"
    rm -f "$TEMP_FILE"
    exit 0
else
    ESLINT_EXIT_CODE=$?
    echo ""
    print_error_with_fix "lint_failures" "ESLint found security issues in staged files"
    rm -f "$TEMP_FILE"
    exit $ESLINT_EXIT_CODE
fi