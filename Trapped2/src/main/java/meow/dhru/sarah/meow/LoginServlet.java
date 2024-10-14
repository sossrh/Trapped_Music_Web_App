package meow.dhru.sarah.meow;

import java.io.IOException;
import java.security.Key;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = -6660883184023703871L;

    // Secret key for JWT generation
    private static final String SECRET_KEY = "4pPqA+7nXy6eV3/O1s+TuK3+hXf43vSgXeUR4uZwvAc=";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Hash the password
        String hashedPassword = hashPassword(password);

        // Perform user authentication
        if (authenticateUser(username, hashedPassword)) {
            // Generate JWT
            String jwtToken = generateJWT(username);

            // Create session and store the username and JWT token
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("jwt", jwtToken);
            
            System.out.println("Session ID: " + session.getId());
            System.out.println("Username: " + session.getAttribute("username"));
            System.out.println("JWT Token: " + session.getAttribute("jwt"));

            response.sendRedirect(request.getContextPath() + "/home.jsp");

        } else {
            // If authentication fails, redirect back to login with an error message
            response.sendRedirect("login.jsp?error=Invalid+username+or+password");
        }
    }

    // Method to hash the password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return java.util.Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // Method to authenticate user by checking against stored credentials in the database
    private boolean authenticateUser(String username, String hashedPassword) {
        String jdbcURL = "jdbc:mariadb://localhost:3308/music_web_app?allowPublicKeyRetrieval=true&useSSL=false";
        String dbUser = "root";
        String dbPassword = "";

        String sql = "SELECT password FROM users WHERE username = ?";

        try (Connection connection = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);

            // Execute the query and get the stored hash
            ResultSet resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String storedHashedPassword = resultSet.getString("password");
                // Compare the stored hashed password with the one provided during login
                return storedHashedPassword.equals(hashedPassword);
            } else {
                return false; // User not found
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error during user authentication", e);
        }
    }

    // Method to generate JWT
    private String generateJWT(String username) {
        Key key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), SignatureAlgorithm.HS256.getJcaName());
        return Jwts.builder()
                .setSubject(username)
                .signWith(key)
                .compact();
    }
    static {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error loading MariaDB JDBC Driver", e);
        }
    }
}
