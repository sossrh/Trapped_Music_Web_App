package meow.dhru.sarah.meow;

public class Track {
    private String name;
    private String artist;
    private String coverImageUrl;
    private String uri; // Add this field for track URI

    public Track(String name, String artist, String coverImageUrl, String uri) {
        this.name = name;
        this.artist = artist;
        this.coverImageUrl = coverImageUrl;
        this.uri = uri; // Initialize this field
    }

    public String getName() {
        return name;
    }

    public String getArtist() {
        return artist;
    }

    public String getCoverImageUrl() {
        return coverImageUrl;
    }

    public String getUri() {
        return uri; // Add this getter
    }
}
