



<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="mytag" uri="http://example.com/tags" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TRAPPED</title>
  <link rel="stylesheet" href="css/login.css">
</head>
<body>
  <div class="wrapper">
    <form action="${pageContext.request.contextPath}/RegistrationServlet" method="post">
      <h2>Registration</h2>
        <div class="input-field">
        <input type="text" name="username"  required >
        <label>Enter your Username</label>
      </div>
      <div class="input-field">
        <input type="text" name="email"  required >
        <label>Enter your Email</label>
      </div>
      <div class="input-field">
        <input type="password" name="password" required>
        <label>Enter your password</label>
      </div>
      <button type="submit" value="Register">Register Yourself</button>
            <div class="register">
        <p>By clicking, you agree to get "Trapped"</p>
      </div>
    </form>
     <mytag:errorDisplay />
  </div>
</body>
</html>
