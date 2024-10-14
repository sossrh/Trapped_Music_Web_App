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
    <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
      <h2>Login</h2>
        <div class="input-field">
        <input type="text" name="username"  required >
        <label>Enter your Username</label>
      </div>
      <div class="input-field">
        <input type="password" name="password" required>
        <label>Enter your password</label>
      </div>
      <div class="forget">
        <label for="remember">
          <input type="checkbox" id="remember">
          <p>Remember me</p>
        </label>
        <a href="${pageContext.request.contextPath}/forget.jsp">Forgot password?</a>
      </div>
      <button type="submit" value="Login">Log In</button>
      <div class="register">
        <p>Don't have an account? <a href="register.jsp">Register</a></p>
      </div>
    </form>
     <mytag:errorDisplay />
  </div>
</body>
</html>