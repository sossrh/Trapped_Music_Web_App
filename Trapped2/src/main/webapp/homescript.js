// Global audio object to play tracks
let audio = new Audio();
let currentTrackUri = ''; // Variable to store the currently playing track's URI

/**
 * Function to play a track.
 * @param {string} trackUri - The Spotify track URI.
 */
async function playTrack(trackUri) {
    if (currentTrackUri !== trackUri) {
        // Fetch track data using the Spotify API
        try {
            // Extract the track ID from the URI
            const trackId = trackUri.split(':')[2];
            
            // Replace with your API endpoint for fetching the track
            const response = await fetch(`https://api.spotify.com/v1/tracks/${trackId}`, {
                headers: {
                    Authorization: `Bearer ${accessToken}` // Use the access token passed from the JSP
                }
            });
            
            if (!response.ok) {
                console.error('Error fetching track data:', response.status, response.statusText);
                return;
            }
            
            const trackData = await response.json();
            // Check if the track has a preview URL
            if (trackData.preview_url) {
                // Stop the currently playing track
                audio.pause();
                audio.src = trackData.preview_url; // Use the preview URL
                audio.play(); // Play the new track
                currentTrackUri = trackUri; // Update the current track
            } else {
                console.log('No preview available for this track.');
            }
        } catch (error) {
            console.error('Error:', error);
        }
    } else {
        // Resume playing the current track if it's paused
        audio.play();
    }
}

/**
 * Function to pause the currently playing track.
 */
function pauseTrack() {
    audio.pause();
}
/**
 * 
 */