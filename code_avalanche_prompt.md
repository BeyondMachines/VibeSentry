CODE GENERATION CONSTRAINTS:
0. Never try to rewrite everything on the next prompt. Explain what should be changed. Then correct one thing at a time and explain!

1. Scope Limits:
   - Each response should contain ONE logical unit (single responsibility)
   - Drive 100 lines per function/method
   - Maximum 200 lines per file/module
   - Provide only next two steps for scaling the solution.

2. Maintainability Requirements:
   - Always ask for previous models or db schema and code
   - Implement rate limiting and resource caps, to be decided by human as parameters
   - Follow DRY principle - identify reusable patterns
   - Use clear, self-documenting variable/function names
   - Add docstrings/JSDoc for all public interfaces
   - Include unit test examples for core logic
   - Suggest refactoring if code exceeds complexity thresholds, but DON'T create everything unless allowed. Even then, follow these same principles.

3. Incremental Development:
   - Start with minimal viable implementation
   - Mark areas that need optimization with TODO comments
   - If not ready for production, flag it in code comments and in any UI
