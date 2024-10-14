<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, org.json.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>

<%
    String artistId = request.getParameter("id");
    String accessToken = (String) session.getAttribute("accessToken");

    if (accessToken != null && artistId != null) {
        try {
            // Fetch Top Tracks
            String topTracksUrl = "https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=US";
            StringBuilder topTracksResponse = new StringBuilder();

            URL url = new URL(topTracksUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);

            // Read Top Tracks response
            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    topTracksResponse.append(inputLine);
                }
                in.close();
            } else {
                out.println("<div class='alert alert-danger'>Error fetching top tracks: " + connection.getResponseCode() + "</div>");
                return;
            }

            // Parse JSON response
            String topTracksJson = topTracksResponse.toString();
            JSONObject topTracksJsonResponse = new JSONObject(topTracksJson);
            JSONArray tracksJsonArray = topTracksJsonResponse.getJSONArray("tracks");

            // Display Top Tracks using enhanced Bootstrap design
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Top Tracks</title>
    <!-- Include Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #000;
            color: #fff;
            font-family: 'Arial', sans-serif;
        }
        .container {
            margin-top: 50px;
        }
        h1 {
            font-size: 3rem;
            text-align: center;
            margin-bottom: 40px;
            font-weight: bold;
        }
        .track-item {
            display: flex;
            align-items: center;
            padding: 20px;
            background-color: #111;
            border-radius: 10px;
            margin-bottom: 20px;
            transition: transform 0.2s ease-in-out;
        }
        .track-item:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 20px rgba(255, 255, 255, 0.1);
        }
        .cover-image {
            width: 80px;
            height: 80px;
            border-radius: 10px;
            margin-right: 20px;
        }
        .track-details {
            flex-grow: 1;
        }
        .track-details strong {
            font-size: 1.5rem;
        }
        .track-details p {
            font-size: 1rem;
            color: #ccc;
        }
        button {
            padding: 10px 20px;
            font-size: 1rem;
            border: none;
            border-radius: 10px;
            background-color: #471f98;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        button:hover {
            background-color: #1e8449;
        }
        audio {
            display: block;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Top Tracks</h1>
        <ul class="list-unstyled">
            <%
                for (int i = 0; i < tracksJsonArray.length(); i++) {
                    JSONObject track = tracksJsonArray.getJSONObject(i);
                    String trackName = track.getString("name");
                    String trackAlbum = track.getJSONObject("album").getString("name");
                    String trackPreviewUrl = track.optString("preview_url", ""); // Empty if no preview is available

                    // Fetch the album cover image URL from the images array
                    JSONArray imagesArray = track.getJSONObject("album").getJSONArray("images");
                    String albumCoverUrl = imagesArray.length() > 0 ? imagesArray.getJSONObject(0).getString("url") : ""; // Get the cover image URL

                    // Assign a unique ID to the audio element for control
                    String audioId = "audio" + i;
            %>
            <li class="track-item">
                <img src="<%= albumCoverUrl %>" alt="<%= trackAlbum %>" class="cover-image">
                <div class="track-details">
                    <strong><%= (i + 1) %>. <%= trackName %></strong>
                    <p>Album: <%= trackAlbum %></p>
                    <%
                        if (!trackPreviewUrl.isEmpty()) {
                    %>
                    <audio id="<%= audioId %>" src="<%= trackPreviewUrl %>"></audio>
                    <button onclick="playTrack('<%= audioId %>')">Play</button>
                    <button onclick="pauseTrack('<%= audioId %>')">Pause</button>
                    <%
                        }
                    %>
                </div>
            </li>
            <%
                }
            %>
        </ul>
    </div>

    <!-- Include Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.min.js"></script>

    <!-- JavaScript to play/pause audio -->
    <script>
        function playTrack(audioId) {
            // Pause all audio elements
            const audios = document.querySelectorAll('audio');
            audios.forEach(audio => {
                audio.pause();
                audio.currentTime = 0; // Reset audio to the beginning
            });
            
            // Play the selected audio
            const audio = document.getElementById(audioId);
            audio.play();
        }

        function pauseTrack(audioId) {
            // Pause the specific audio element
            const audio = document.getElementById(audioId);
            audio.pause();
        }
    </script>
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
