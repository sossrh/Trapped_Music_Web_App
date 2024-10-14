<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="meow.dhru.sarah.meow.Track" %>
<html>
<head>
    <title>Search Music</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-image: url('images/skull.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: white;
        }

        .container {
            background-color: rgba(0, 0, 0, 0.7);
            padding: 20px;
            border-radius: 10px;
        }

        .card {
            background-color: #ffffff;
            color: #000000;
            border: 1px solid #000;
        }

        .btn-primary {
            background-color: #000;
            border: none;
        }

        .btn-primary:hover {
            background-color: #555;
        }

        h3 {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2 class="my-4">Search Music</h2>

        <!-- Search Form -->
        <form action="<%= request.getContextPath() %>/SearchServlet" method="get" class="form-inline mb-4">
            <div class="form-group mx-sm-3 mb-2">
                <label for="query" class="sr-only">Search</label>
                <input type="text" name="query" id="query" class="form-control" placeholder="Enter a song or artist" required>
            </div>
            <button type="submit" class="btn btn-primary mb-2">Search</button>
        </form>

        <h3>Search Results:</h3>

        <div class="row">
            <c:forEach var="track" items="${searchResults}">
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card">
                        <img class="card-img-top" src="${track.coverImageUrl}" alt="Cover image for ${track.name}">
                        
                        <div class="card-body">
                            <h5 class="card-title">${track.name}</h5>
                            <p class="card-text">by ${track.artist}</p>
                            <button class="btn btn-primary" onclick="playTrack('${track.uri}')">Play</button>
                            <button class="btn btn-secondary" onclick="pauseTrack()">Pause</button>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <%
            if (request.getAttribute("searchResults") != null) {
                System.out.println("Search results count: " + ((ArrayList<Track>) request.getAttribute("searchResults")).size());
            } else {
                System.out.println("No search results found.");
            }
        %>
    </div>

    <%
        // Set the access token as a variable directly into the script
        String accessToken = (String) request.getAttribute("accessToken");
        System.out.println("Access Token: " + accessToken);
    %>

    <script>
        // Declare accessToken directly from JSP
        var accessToken = '<%= accessToken != null ? accessToken : "" %>';
    </script>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="<%= request.getContextPath() %>/homescript.js"></script>
</body>
</html>
