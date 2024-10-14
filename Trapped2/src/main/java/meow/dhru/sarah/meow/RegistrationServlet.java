package meow.dhru.sarah.meow;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Properties;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegistrationServlet")
public class RegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Hash the password
        String hashedPassword = hashPassword(password);

        // Save the user details in the database
        saveUserDetails(username, email, hashedPassword);

        // Generate and send OTP
        String otp = generateOTP();
        saveOTP(email, otp); // Save OTP for verification
        sendOTPEmail(email, otp);

        // Store email in session for retrieval during OTP verification
        request.getSession().setAttribute("email", email);

        // Redirect to OTP verification page
        response.sendRedirect("otpVerification.jsp");
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

    // Method to save user details in the database
    private void saveUserDetails(String username, String email, String hashedPassword) {
        String jdbcURL = "jdbc:mariadb://localhost:3308/music_web_app?allowPublicKeyRetrieval=true&useSSL=false";
        String dbUser = "root";
        String dbPassword = "sarah";

        String sql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";

        try (Connection connection = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);
            statement.setString(2, email);
            statement.setString(3, hashedPassword);

            statement.executeUpdate();
            System.out.println("User details saved successfully for: " + email);
        } catch (SQLException e) {
            throw new RuntimeException("Error saving user details", e);
        }
    }

    // Method to generate a random OTP
    private String generateOTP() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000); // Generates a 6-digit OTP
        return String.valueOf(otp);
    }

    // Method to save the OTP in the database (temporary storage)
    private void saveOTP(String email, String otp) {
        String jdbcURL = "jdbc:mariadb://localhost:3308/music_web_app?allowPublicKeyRetrieval=true&useSSL=false";
        String dbUser = "root";
        String dbPassword = "sarah";

        String sql = "UPDATE users SET otp = ? WHERE email = ?";

        try (Connection connection = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, otp);
            statement.setString(2, email);

            int rowsUpdated = statement.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("OTP saved successfully for email: " + email);
            } else {
                System.out.println("Failed to save OTP for email: " + email);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error saving OTP", e);
        }
    }

    // Method to send the OTP via email
    private void sendOTPEmail(String recipientEmail, String otp) {
        String senderEmail = "YOUR_EMAIL";
        String senderPassword = "YOUR_EMAIL_PASS"; // Less Secure App Password Prefered

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // Enable STARTTLS
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587"); // Use 465 for SSL
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        System.out.println("Generated Props");
        
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
        	@Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });
        
//        session.setDebug(true);
        
        System.out.println("Session Instance Created");

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your OTP Code");
            message.setText("Your OTP code is: " + otp);
            System.out.println("Sending Msg");
            Transport.send(message);
            System.out.println("OTP sent successfully to: " + recipientEmail);
        } catch (Exception e) {
            throw new RuntimeException("Error sending OTP email", e);
        }
    }

    // JDBC Driver loading
    static {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error loading MariaDB JDBC Driver", e);
        }
    }
}
