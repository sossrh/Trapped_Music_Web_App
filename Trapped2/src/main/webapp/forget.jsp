<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Try to Remember</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"> <!-- Font Awesome for icons -->
    <style>
        body {
            background-color: #100e11; /* Black background */
            color: #fff; /* White text */
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh; /* Full height of the viewport */
            text-align: center;
        }
        .ghost-image {

        }
    </style>
</head>
<body>

    <div class="container">
        <img src="https://i.ibb.co/NrjvWkP/enigmatic-elegance-ghost-sticker-s-blackbacked-white-border-983420-18195.jpg" alt="Ghost Icon" class="ghost-image"> <!-- New ghost image -->
        <h1 class="display-4">Try to Remember</h1>
        <p class="lead">It's the only topic that matters.</p>
        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-light btn-lg">Go to Login</a> <!-- White button -->
    </div>

    <!-- Bootstrap JS (optional, for interactive components) -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
