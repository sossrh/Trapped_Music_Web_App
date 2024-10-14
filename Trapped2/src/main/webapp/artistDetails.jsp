<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, org.json.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>

<%
    String artistId = request.getParameter("id");
    String accessToken = (String) session.getAttribute("accessToken");

    if (accessToken != null && artistId != null) {
        try {
            // Fetch Artist Details
            String artistDetailsUrl = "https://api.spotify.com/v1/artists/" + artistId;
            StringBuilder artistDetailsResponse = new StringBuilder();

            URL url = new URL(artistDetailsUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);

            // Read Artist Details response
            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    artistDetailsResponse.append(inputLine);
                }
                in.close();
            } else {
                out.println("<div class='alert alert-danger'>Error fetching artist details: " + connection.getResponseCode() + "</div>");
                return;
            }

            // Parse JSON response
            String artistDetailsJson = artistDetailsResponse.toString();
            JSONObject artistJsonResponse = new JSONObject(artistDetailsJson);
            String artistName = artistJsonResponse.getString("name");
            String artistGenre = artistJsonResponse.getJSONArray("genres").join(", ").replaceAll("\"", "");
            String artistImageUrl = artistJsonResponse.getJSONArray("images").getJSONObject(0).getString("url");
            int followersCount = artistJsonResponse.getJSONObject("followers").getInt("total");
            int popularity = artistJsonResponse.getInt("popularity");
            String spotifyUrl = artistJsonResponse.getJSONObject("external_urls").getString("spotify");

            // Display Artist Details with Bootstrap dark theme
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Artist Details</title>
    <!-- Include Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-black text-white">
    <div class="container mt-5 p-4 rounded">
        <div class="row">
            <div class="col-md-4 text-center">
                <img src="<%= artistImageUrl %>" class="img-fluid rounded" alt="<%= artistName %>" style="max-width: 100%;">
            </div>
            <div class="col-md-8">
                <h1 class="display-4 text-white"><%= artistName %></h1>
                <p class="text-white-50">Genres: <%= artistGenre %></p>
                <p>Followers: <%= String.format("%,d", followersCount) %></p>
                <p>Popularity: <%= popularity %> / 100</p>
                <p>
                    <a href="<%= spotifyUrl %>" class="btn btn-outline-light" target="_blank">Listen on Spotify</a>
                </p>
                <button class="btn btn-light mt-3" onclick="window.location.href='topTracks.jsp?id=<%= artistId %>';">Get Top Tracks</button>
            </div>
        </div>
    </div>

    <!-- Include Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.min.js"></script>
</body>
</html>
<%
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    } else {
        out.println("<div class='alert alert-warning'>Access token not available or invalid artist ID.</div>");
    }
%>
