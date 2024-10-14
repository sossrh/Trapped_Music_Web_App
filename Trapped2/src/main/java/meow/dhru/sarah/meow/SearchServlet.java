package meow.dhru.sarah.meow;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Base64;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = -6664121247140222278L;

    private String clientId = "1ef929a99cd3429c8fecd0059336ba7b"; // Your Spotify client ID
    private String clientSecret = "20c44572a80b4c96b8a4a73c13dd6ea8"; // Your Spotify client secret

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String query = request.getParameter("query");

        // Get Spotify access token
        String accessToken = getSpotifyAccessToken();
        System.out.println("Acess Token when creating in search: " + accessToken);

        // Perform search on Spotify API
        ArrayList<Track> searchResults = searchSpotify(query, accessToken);

        // Set search results and access token in request attributes
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("accessToken", accessToken); // Set access token as a request attribute
        
        // Debugging output
        System.out.println("Search results count: " + searchResults.size());
        System.out.println("Access Token: " + accessToken); // Log the access token

        // Forward to JSP
        request.getRequestDispatcher("search.jsp").forward(request, response);
    }

    private String getSpotifyAccessToken() throws IOException {
        URL url = new URL("https://accounts.spotify.com/api/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Basic " + Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes()));
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream());
        writer.write("grant_type=client_credentials");
        writer.flush();

        JsonReader reader = Json.createReader(new InputStreamReader(conn.getInputStream()));
        JsonObject json = reader.readObject();
        reader.close();
        writer.close();

        return json.getString("access_token");
    }

    private ArrayList<Track> searchSpotify(String query, String accessToken) throws IOException {
        ArrayList<Track> results = new ArrayList<>();
        URL url = new URL("https://api.spotify.com/v1/search?q=" + query + "&type=track&limit=12");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        JsonReader reader = Json.createReader(new InputStreamReader(conn.getInputStream()));
        JsonObject json = reader.readObject();
        JsonArray tracks = json.getJsonObject("tracks").getJsonArray("items");

        for (JsonObject track : tracks.getValuesAs(JsonObject.class)) {
            String trackName = track.getString("name");
            String artistName = track.getJsonArray("artists").getJsonObject(0).getString("name");
            String coverImageUrl = track.getJsonObject("album").getJsonArray("images").getJsonObject(0).getString("url");
            String trackUri = track.getString("uri"); // Get the track URI
            results.add(new Track(trackName, artistName, coverImageUrl, trackUri)); // Pass trackUri
        }

        reader.close();
        return results;
    }
}
