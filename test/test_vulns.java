/**
 * Test file for Semgrep security scanning
 * Contains various security vulnerabilities for testing
 */

import java.sql.*;
import java.io.*;
import javax.servlet.http.*;
import java.security.MessageDigest;
import java.util.Random;

public class TestVulnerabilities {
    
    // Hardcoded credentials
    private static final String DB_PASSWORD = "admin123";
    private static final String API_KEY = "sk-1234567890abcdef";
    
    // SQL Injection vulnerability
    public User getUserById(String userId) throws SQLException {
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost/app", "user", DB_PASSWORD);
        
        // VULNERABLE: String concatenation in SQL query
        String query = "SELECT * FROM users WHERE id = " + userId;
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(query);
        
        if (rs.next()) {
            return new User(rs.getString("name"), rs.getString("email"));
        }
        return null;
    }
    
    // Command Injection vulnerability
    public String executeCommand(String filename) throws IOException {
        // VULNERABLE: Direct user input in ProcessBuilder
        ProcessBuilder pb = new ProcessBuilder("cat", filename);
        Process process = pb.start();
        
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getInputStream()));
        
        StringBuilder result = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            result.append(line).append("\n");
        }
        
        return result.toString();
    }
    
    // Path Traversal vulnerability
    public void downloadFile(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String filename = request.getParameter("file");
        
        // VULNERABLE: No path validation
        String filePath = "/var/app/files/" + filename;
        File file = new File(filePath);
        
        if (file.exists()) {
            FileInputStream fis = new FileInputStream(file);
            OutputStream out = response.getOutputStream();
            
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            fis.close();
        }
    }
    
    // IDOR vulnerability - Direct object access
    public UserProfile getUserProfile(String userId, String requestingUserId) 
            throws SQLException {
        // VULNERABLE: No authorization check
        // Any user can access any other user's profile
        
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost/app", "user", DB_PASSWORD);
        
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT * FROM user_profiles WHERE user_id = ?");
        stmt.setString(1, userId);
        
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return new UserProfile(
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("ssn")  // Sensitive data exposed
            );
        }
        return null;
    }
    
    // Weak cryptography
    public String hashPassword(String password) throws Exception {
        // VULNERABLE: MD5 is cryptographically broken
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update(password.getBytes());
        
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
    
    // Insecure random number generation
    public String generateSessionToken() {
        Random random = new Random();  // VULNERABLE: Not cryptographically secure
        
        StringBuilder token = new StringBuilder();
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        
        for (int i = 0; i < 32; i++) {
            token.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return token.toString();
    }
    
    // XSS vulnerability - Reflected XSS
    public void searchResults(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String query = request.getParameter("q");
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        // VULNERABLE: Direct output of user input without escaping
        out.println("<html><body>");
        out.println("<h1>Search Results</h1>");
        out.println("<p>You searched for: " + query + "</p>");
        out.println("</body></html>");
    }
    
    // LDAP Injection vulnerability
    public boolean authenticateUser(String username, String password) {
        try {
            javax.naming.directory.DirContext ctx = null;
            
            // VULNERABLE: LDAP injection
            String filter = "(&(uid=" + username + ")(userPassword=" + password + "))";
            
            javax.naming.directory.SearchControls searchControls = 
                new javax.naming.directory.SearchControls();
            searchControls.setSearchScope(javax.naming.directory.SearchControls.SUBTREE_SCOPE);
            
            javax.naming.NamingEnumeration<javax.naming.directory.SearchResult> results = 
                ctx.search("dc=example,dc=com", filter, searchControls);
            
            return results.hasMore();
        } catch (Exception e) {
            return false;
        }
    }
    
    // Sensitive data classes
    public class User {
        public String name;
        public String email;
        
        public User(String name, String email) {
            this.name = name;
            this.email = email;
        }
    }
    
    public class UserProfile {
        public String name;
        public String email;
        public String phone;
        public String ssn;  // Sensitive data
        
        public UserProfile(String name, String email, String phone, String ssn) {
            this.name = name;
            this.email = email;
            this.phone = phone;
            this.ssn = ssn;
        }
    }
}