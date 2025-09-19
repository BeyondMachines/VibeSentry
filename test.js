// ESLint Security Test File
// This file should trigger multiple ESLint security warnings

const { exec } = require('child_process');
const fs = require('fs');

// 1. eval() usage - should trigger no-eval
function badEval(userInput) {
    eval(userInput);
}

// 2. Command injection - should trigger security/detect-child-process
function badCommand(userInput) {
    exec("ls " + userInput);
}

// 3. XSS via innerHTML - should trigger no-unsanitized/property
function badXSS(userInput) {
    document.body.innerHTML = userInput;
}

// 4. XSS via document.write - should trigger no-unsanitized/method
function badDOM(userInput) {
    document.write(userInput);
}

// 5. File path injection - should trigger security/detect-non-literal-fs-filename
function badFile(userInput) {
    fs.readFile(userInput, 'utf8', console.log);
}

// 6. Dynamic require - should trigger security/detect-non-literal-require
function badRequire(userInput) {
    const module = require(userInput);
}

// 7. Object injection - should trigger security/detect-object-injection
function badObject(userInput) {
    const obj = {};
    return obj[userInput];
}

// 8. setTimeout with string - should trigger no-implied-eval
function badSetTimeout(userInput) {
    setTimeout(userInput, 1000);
}

// 9. Function constructor - should trigger security rules
function badFunction(userInput) {
    const fn = new Function(userInput);
    return fn();
}

// 10. Unsafe regex - should trigger security/detect-unsafe-regex
function badRegex(userInput) {
    const regex = new RegExp(userInput);
    return regex.test('test');
}

module.exports = {
    badEval,
    badCommand,
    badXSS,
    badDOM,
    badFile,
    badRequire,
    badObject,
    badSetTimeout,
    badFunction,
    badRegex
};