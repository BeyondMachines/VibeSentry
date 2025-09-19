CRITICAL SECURITY REQUIREMENTS:
0. Assume all user input can be malicious

1. NEVER include:
   - Hardcoded credentials, API keys, or secrets
   - Direct string concatenation for SQL/commands
   - Unvalidated user input in system calls
   - Predictable random values for security purposes
   - Disabled security features (even temporarily)

2. ALWAYS implement:
   - Parameterized queries for all database operations
   - Input sanitization using established libraries
   - Proper authentication and authorization checks
   - Secure random generation for tokens/IDs
   - Least privilege principle for all operations
   - Output encoding for different contexts (HTML, URL, JS)
   - Output and error sanitization (no verbose errors in UI, only on debug console)
   - Latest possible third party packages/libraries. If not certain, ask the user to check.

3. For each function/module, explicitly comment:
   - Security considerations
   - Trust boundaries
   - Required validations
   - Potential attack vectors addressed

When uncertain about security implications, err on the side of caution and note areas requiring security review.