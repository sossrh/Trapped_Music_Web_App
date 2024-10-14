package meow.dhru.sarah.meow;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/OTPVerificationServlet")
public class OTPVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String otp = request.getParameter("otp");
        String email = (String) request.getSession().getAttribute("email");

        if (email == null) {
            System.out.println("No email found in session");
            response.sendRedirect("otpVerification.jsp?error=Session+Expired");
            return;
        }

        // Validate OTP
        if (validateOTP(email, otp)) {
            response.sendRedirect("login.jsp");
        } else {
            response.sendRedirect("otpVerification.jsp?error=Invalid+OTP");
        }
    }

    // Method to validate OTP from the database
    private boolean validateOTP(String email, String otp) {
        String jdbcURL = "jdbc:mariadb://localhost:3308/music_web_app?allowPublicKeyRetrieval=true&useSSL=false";
        String dbUser = "root";
        String dbPassword = "sarah";

        String sql = "SELECT otp FROM users WHERE email = ?";

        try (Connection connection = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    String storedOtp = resultSet.getString("otp");
                    return storedOtp.equals(otp); // Check if OTP matches
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error validating OTP", e);
        }  

        return false;
    }
}
