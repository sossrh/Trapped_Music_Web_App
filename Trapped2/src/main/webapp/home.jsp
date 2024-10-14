<%@ page contentType="text/html;charset=UTF-8" language="java" %> 
<%@ page import="java.io.*, java.net.*, org.json.*" %> 
<%@ page import="javax.servlet.*, javax.servlet.http.*" %> 
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Top Songs & Artists</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="css/home.css"> <!-- Your custom CSS file -->
    <style>
        body {
            background-color: #000; /* Black background */
            color: #fff; /* White text */
        }
        .container {
            margin-top: 30px;
        }
        .horizontal-container {
            display: flex;
            overflow-x: auto;
            white-space: nowrap;
            
        }
        .item {
            background-color: #1c1c1c; /* Darker item background */
            margin-right: 15px;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            min-width: 150px;
        }
        .item img {
            width: 100%; /* Responsive image */
            border-radius: 5px;
        }
        .title, .artist {
            margin-top: 5px;
            font-size: 14px;
        }
        .play-button, .pause-button, .search-button {
            margin-top: 5px;
            border: none;
            border-radius: 5px;
            padding: 5px 10px;
            background-color: #fff; /* White button */
            color: #000; /* Black text */
            cursor: pointer;
        }
        .search-button {
            background-color: #007bff; /* Bootstrap primary color */
            color: #fff; /* White text */
        }
    </style>
</head>
<body>
<%
    // Spotify API credentials
    String clientId = "YOUR_CLIENT_ID"; //  Client ID
    String clientSecret = "YOUR_CLIENT_SECRET"; //  Client Secret
    String redirectUri = "http://localhost:8080/Trapped2/home.jsp"; // Your Redirect URI
    String authorizationCode = request.getParameter("code");
    String accessToken = (String) session.getAttribute("accessToken"); // Get access token from session
    String refreshToken = (String) session.getAttribute("refreshToken"); // Get refresh token from session

    // Debugging Information
    System.out.println("<h2>Debugging Information:</h2>");
    System.out.println("<p>Authorization Code: " + authorizationCode + "</p>");
    System.out.println("<p>Session Access Token: " + accessToken + "</p>");
    System.out.println("<p>Session Refresh Token: " + refreshToken + "</p>");

    // Function to get access token if authorization code is available
    if (authorizationCode != null) {
        try {
            String tokenUrl = "https://accounts.spotify.com/api/token";
            StringBuilder tokenResponseBuilder = new StringBuilder();

            // Prepare the request for token exchange
            String params = "grant_type=authorization_code&code=" + authorizationCode +
                            "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8") +
                            "&client_id=" + clientId +
                            "&client_secret=" + clientSecret;

            URL url = new URL(tokenUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            // Send the request
            try (OutputStream os = connection.getOutputStream()) {
                os.write(params.getBytes());
                os.flush();
            }

            // Read the response for the access token
            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;

                while ((inputLine = in.readLine()) != null) {
                    tokenResponseBuilder.append(inputLine);
                }
                in.close();

                // Print the entire response for debugging
                out.println("<p>Token Response: " + tokenResponseBuilder.toString() + "</p>");

                // Parse JSON response
                JSONObject jsonResponse = new JSONObject(tokenResponseBuilder.toString());
                accessToken = jsonResponse.getString("access_token");
                session.setAttribute("accessToken", accessToken); // Store the access token in the session
                
                // Check for refresh token and store it
                if (jsonResponse.has("refresh_token")) {
                    refreshToken = jsonResponse.getString("refresh_token");
                    session.setAttribute("refreshToken", refreshToken); // Store refresh token
                    // Redirect to avoid reusing the authorization code
                    response.sendRedirect("home.jsp"); // Redirect to your home page or main page
                    return; // Stop further processing
                }
            } else {
                out.println("Error: Unable to fetch access token. Response Code: " + connection.getResponseCode());
                return;
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            return;
        }
    }
    // Refresh the access token if it is not available
    if (accessToken == null) {
        if (refreshToken != null) {
            try {
                String refreshTokenUrl = "https://accounts.spotify.com/api/token";
                StringBuilder refreshResponseBuilder = new StringBuilder();

                // Prepare the request for token refresh
                String refreshParams = "grant_type=refresh_token&refresh_token=" + refreshToken +
                                       "&client_id=" + clientId +
                                       "&client_secret=" + clientSecret;

                URL url = new URL(refreshTokenUrl);
                HttpURLConnection refreshConnection = (HttpURLConnection) url.openConnection();
                refreshConnection.setRequestMethod("POST");
                refreshConnection.setDoOutput(true);
                refreshConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

                // Send the refresh request
                try (OutputStream os = refreshConnection.getOutputStream()) {
                    os.write(refreshParams.getBytes());
                    os.flush();
                }

                // Read the response for the refreshed access token
                if (refreshConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                    BufferedReader in = new BufferedReader(new InputStreamReader(refreshConnection.getInputStream()));
                    String inputLine;

                    while ((inputLine = in.readLine()) != null) {
                        refreshResponseBuilder.append(inputLine);
                    }
                    in.close();

                    // Parse JSON response
                    JSONObject jsonResponse = new JSONObject(refreshResponseBuilder.toString());
                    accessToken = jsonResponse.getString("access_token");
                    session.setAttribute("accessToken", accessToken); // Store the new access token in the session
                } else {
                    out.println("Error: Unable to refresh access token. Response Code: " + refreshConnection.getResponseCode());
                    return;
                }
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
                return;
            }
        } else {
            // Redirect user for authentication if no access token or refresh token
            String authUrl = "https://accounts.spotify.com/authorize?client_id=" + clientId +
                             "&response_type=code&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8") +
                             "&scope=user-top-read user-modify-playback-state"; // Add necessary scope
            out.println("<script>window.location.href='" + authUrl + "';</script>");
            return; // Stop further processing
        }
    }

    // If access token is available, fetch top tracks and artists
    if (accessToken != null) {
        try {
            // Fetch Top Tracks
            String topTracksUrl = "https://api.spotify.com/v1/me/top/tracks?limit=30"; 
            StringBuilder topTracksResponse = new StringBuilder();
            
            URL tracksUrl = new URL(topTracksUrl);
            HttpURLConnection tracksConnection = (HttpURLConnection) tracksUrl.openConnection();
            tracksConnection.setRequestMethod("GET");
            tracksConnection.setRequestProperty("Authorization", "Bearer " + accessToken);

            // Fetch Top Artists
            String topArtistsUrl = "https://api.spotify.com/v1/me/top/artists?limit=20"; 
            StringBuilder topArtistsResponse = new StringBuilder();
            
            URL artistsUrl = new URL(topArtistsUrl);
            HttpURLConnection artistsConnection = (HttpURLConnection) artistsUrl.openConnection();
            artistsConnection.setRequestMethod("GET");
            artistsConnection.setRequestProperty("Authorization", "Bearer " + accessToken);

            // Read Top Tracks response
            if (tracksConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(tracksConnection.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    topTracksResponse.append(inputLine);
                }
                in.close();
            } else {
                out.println("Error fetching top tracks: " + tracksConnection.getResponseCode());
                return;
            }

            // Read Top Artists response
            if (artistsConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(artistsConnection.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    topArtistsResponse.append(inputLine);
                }
                in.close();
            } else {
                out.println("Error fetching top artists: " + artistsConnection.getResponseCode());
                return;
            }

            // Parse JSON responses
            JSONObject tracksJsonResponse = new JSONObject(topTracksResponse.toString());
            JSONArray tracks = tracksJsonResponse.getJSONArray("items");

            JSONObject artistsJsonResponse = new JSONObject(topArtistsResponse.toString());
            JSONArray artists = artistsJsonResponse.getJSONArray("items");
            
            out.println("<script>var accessToken = '" + accessToken + "';</script>");

            // Display Top Tracks and Artists
            out.println("<div class='container'>");
            out.println("<h1>Top Songs & Artists on Spotify</h1>");
            out.println("<div class='container'>");

            // Top Tracks
            out.println("<h2>Top Songs</h2>");
            out.println("<div class='horizontal-container'>");
            for (int i = 0; i < tracks.length(); i++) {
                JSONObject track = tracks.getJSONObject(i);
                JSONObject album = track.getJSONObject("album");
                String songTitle = track.getString("name");
                String artistName = track.getJSONArray("artists").getJSONObject(0).getString("name");
                String imageUrl = album.getJSONArray("images").getJSONObject(0).getString("url");
                String trackUri = track.getString("uri"); // Track URI for potential use

                // Check if the track has a preview URL
                if (track.has("preview_url") && !track.isNull("preview_url")) {
                    out.println("<div class='item'>");
                    out.println("<img src='" + imageUrl + "' alt='" + songTitle + " Cover'>");
                    out.println("<div class='title'>" + songTitle + "</div>");
                    out.println("<div class='artist'>" + artistName + "</div>");
                    out.println("<button class='play-button' onclick=\"playTrack('" + trackUri + "')\">Play</button>");
                    out.println("<button class='pause-button' onclick=\"pauseTrack()\">Pause</button>");
                    out.println("</div>");
                }
            }
            out.println("</div>");

            // Top Artists
            out.println("<h2>Top Artists</h2>");
            out.println("<div class='horizontal-container'>");
            for (int i = 0; i < artists.length(); i++) {
                JSONObject artist = artists.getJSONObject(i);
                String artistName = artist.getString("name");
                String artistId = artist.getString("id"); // Get the artist ID from the artist object

                String imageUrl = artist.getJSONArray("images").getJSONObject(0).getString("url");

                out.println("<div class='item'>");
                out.println("<a href='artistDetails.jsp?id=" + artistId + "'>");
                
                out.println("<img src='" + imageUrl + "' alt='" + artistName + " Image'>");
                out.println("<div class='title'>" + artistName + "</div>");
                out.println("</a>");
                out.println("</div>");
            }
            out.println("</div>");
            // Add a button to navigate to search.jsp
            out.println("<br><br>");
            out.println("<div class='search-button-container'>");
            out.println("<a href='search.jsp' class='search-button'>Search Music</a>");
            out.println("</div>");
            
            out.println("</div>");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    } else {
        // Redirect user for authentication
        String authUrl = "https://accounts.spotify.com/authorize?client_id=" + clientId +
                         "&response_type=code&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8") +
                         "&scope=user-top-read user-modify-playback-state"; // Add necessary scope
        out.println("<script>window.location.href='" + authUrl + "';</script>");
    }
%>

<!-- Bootstrap JS and dependencies -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script src="homescript.js"></script> <!-- Path to your JavaScript file -->
</body>
</html>
