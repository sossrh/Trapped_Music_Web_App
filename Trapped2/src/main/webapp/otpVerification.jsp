<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTP Verification</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #000; /* Black background */
            color: #fff; /* White text */
        }
        .form-container {
            margin-top: 100px;
            background-color: #333; /* Dark form background */
            padding: 30px;
            border-radius: 10px;
        }
        .btn-custom {
            background-color: #fff;
            color: #000;
        }
        .btn-custom:hover {
            background-color: #ddd;
        }
        input {
            background-color: #555;
            color: #fff;
        }
        input::placeholder {
            color: #ccc;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 form-container">
                <h2 class="text-center">OTP Verification</h2>
                <form action="OTPVerificationServlet" method="post">
                    <input type="hidden" name="email" value="<%= session.getAttribute("email") %>">
                    <div class="form-group">
                        <label for="otp">Enter OTP:</label>
                        <input type="text" class="form-control" id="otp" name="otp" placeholder="Enter OTP" required>
                    </div>
                    <button type="submit" class="btn btn-custom btn-block">Verify OTP</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS and dependencies (optional, for JS components) -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
