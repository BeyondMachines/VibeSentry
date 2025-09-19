#!/usr/bin/env python3
"""
Test file for Semgrep security scanning
Contains various security vulnerabilities for testing
"""

import sqlite3
import subprocess
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

# SQL Injection vulnerability
def get_user_data(user_id):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    # VULNERABLE: Direct string formatting in SQL query
    query = f"SELECT * FROM users WHERE id = {user_id}"
    cursor.execute(query)
    return cursor.fetchall()

# Command Injection vulnerability  
def process_file(filename):
    # VULNERABLE: Direct user input in system command
    command = f"cat {filename} | wc -l"
    result = subprocess.run(command, shell=True, capture_output=True)
    return result.stdout

# IDOR vulnerability - missing authorization
@app.route('/api/user/<int:user_id>/profile')
def get_user_profile(user_id):
    # VULNERABLE: No authorization check - any user can access any profile
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute("SELECT name, email, phone FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    
    if user:
        return jsonify({
            'name': user[0],
            'email': user[1], 
            'phone': user[2]
        })
    return jsonify({'error': 'User not found'}), 404

# Path Traversal vulnerability
@app.route('/api/files/<path:filename>')
def serve_file(filename):
    # VULNERABLE: No path validation
    file_path = f"/var/app/uploads/{filename}"
    
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            return f.read()
    return "File not found", 404

# Hardcoded secrets
DATABASE_PASSWORD = "super_secret_password_123"
API_KEY = "sk-1234567890abcdef"

# Weak cryptography
import hashlib

def weak_hash(password):
    # VULNERABLE: MD5 is cryptographically broken
    return hashlib.md5(password.encode()).hexdigest()

# LDAP Injection
def authenticate_user(username, password):
    import ldap
    
    # VULNERABLE: LDAP injection
    search_filter = f"(&(uid={username})(password={password}))"
    
    ldap_conn = ldap.initialize("ldap://localhost")
    result = ldap_conn.search_s("dc=example,dc=com", ldap.SCOPE_SUBTREE, search_filter)
    return len(result) > 0

if __name__ == "__main__":
    app.run(debug=True)  # VULNERABLE: Debug mode in production