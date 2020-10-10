package at.etrax.background_location.database;

import android.location.Location;
import android.os.Build;

import java.util.HashMap;

public class Converters {
    /**
     * Convert Location object to LocationData. Optionally use a different altitude value
     * (i.e. the one supplied by the NMEA message listener on newer Android versions).
     *
     * @param location
     * @param altitude
     * @return
     */
    public static LocationData convertLocationToLocationData(Location location, Double altitude, String label) {
        LocationData locationData = new LocationData();

        locationData.latitude = location.getLatitude();
        locationData.longitude = location.getLongitude();
        locationData.accuracy = location.getAccuracy();

        // Using NMEA Data to get MSL level altitude
        if (altitude == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            locationData.altitude = location.getAltitude();
        } else {
            locationData.altitude = altitude;
        }
        if(location.getSpeed() > 0.0f) {
            locationData.speed = location.getSpeed();
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if(location.getSpeedAccuracyMetersPerSecond() > 0.0f) {
                locationData.speedAccuracy = location.getSpeedAccuracyMetersPerSecond();
            }
        }
        if(label != null) {
            locationData.label = label;
        }

        if(location.getBearing() > 0.0f) {
            locationData.heading = location.getBearing();
        }
        locationData.time = location.getTime();

        return locationData;
    }

    public static HashMap<String, Object> convertLocationDataToHashMap(LocationData locationData) {
        HashMap<String, Object> loc = new HashMap<>();
        loc.put("latitude", locationData.latitude);
        loc.put("longitude", locationData.longitude);
        loc.put("accuracy", (double) locationData.accuracy);
        loc.put("altitude", locationData.altitude);

        loc.put("speed", (double) locationData.speed);
            loc.put("speed_accuracy", (double) locationData.speedAccuracy);
        loc.put("heading", (double) locationData.heading);
        loc.put("time", (double) locationData.time);
        loc.put("label", locationData.label);
        return loc;
    }

    public static HashMap<String, Object> convertLocationToHashMap(Location location) {
        HashMap<String, Object> loc = new HashMap<>();
        loc.put("latitude", location.getLatitude());
        loc.put("longitude", location.getLongitude());
        loc.put("accuracy", (double) location.getAccuracy());
        loc.put("altitude", location.getAltitude());

        loc.put("speed", (double) location.getSpeed());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            loc.put("speed_accuracy", (double) location.getSpeedAccuracyMetersPerSecond());
        } else {
            loc.put("speed_accuracy", -1.0);
        }
        loc.put("heading", (double) location.getBearing());
        loc.put("time", (double) location.getTime());
        return loc;
    }
}
