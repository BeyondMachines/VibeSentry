# VibeSentry
Simple tools to help VibeCoders to avoid the most common security mistakes

# Testing Pre-commit Hooks
1. Install Pre-commit (if not already done)
bashpip install pre-commit
pre-commit install

2. Test Individual Hooks
bash# Test specific hook by ID
pre-commit run gitleaks-detector
pre-commit run injection-detector  
pre-commit run idor-detector

# Test with verbose output
pre-commit run gitleaks-detector --verbose
3. Test All Hooks
bash# Run all hooks on all files
pre-commit run --all-files

# Run all hooks on all files with verbose output
pre-commit run --all-files --verbose
4. Test on Staged Files Only
bash# Stage some files first
git add .

# Run hooks on staged files (normal pre-commit behavior)
pre-commit run
