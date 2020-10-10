package at.etrax.background_location;

import androidx.annotation.NonNull;

import com.google.android.gms.location.LocationRequest;

import java.util.HashMap;
import java.util.List;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

class MethodCallHandlerImpl implements MethodCallHandler {

    final static String TAG = "CallHandler";

    private MethodChannel mChannel;

    private PluginState mPluginState;

    MethodCallHandlerImpl(PluginState state) {
        mPluginState = state;
    };

    public HashMap<Integer, Integer> mapFlutterAccuracy = new HashMap<Integer, Integer>() {
        {
            put(0, LocationRequest.PRIORITY_NO_POWER);
            put(1, LocationRequest.PRIORITY_LOW_POWER);
            put(2, LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
            put(3, LocationRequest.PRIORITY_HIGH_ACCURACY);
            put(4, LocationRequest.PRIORITY_HIGH_ACCURACY);
        }
    };

    private LocationRequest createLocationRequest(
            Integer locationAccuracy,
            long updateIntervalMilliseconds,
            long fastestUpdateIntervalMilliseconds,
            float distanceFilter) {
        LocationRequest locationRequest = LocationRequest.create();

        locationRequest.setInterval(updateIntervalMilliseconds);
        locationRequest.setFastestInterval(fastestUpdateIntervalMilliseconds);
        locationRequest.setPriority(locationAccuracy);
        locationRequest.setSmallestDisplacement(distanceFilter);
        return locationRequest;
    }

    /**
     * Registers this instance as a method call handler on the given
     * {@code messenger}.
     */
    void startListening(BinaryMessenger messenger) {
        if (mChannel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.");
            stopListening();
        }

        mChannel = new MethodChannel(messenger, "at.etrax.background_location/method");
        mChannel.setMethodCallHandler(this);
    }

    /**
     * Clears this instance from listening to method calls.
     */
    void stopListening() {
        if (mChannel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.");
            return;
        }
        mChannel.setMethodCallHandler(null);
        mChannel = null;
    }

    private void onHasPermission(MethodChannel.Result result) {
        mPluginState.hasPermission(result);
    }

    private void onRequestPermission(MethodChannel.Result result) {
        mPluginState.requestPermission(result);
    }

    private void onServiceEnabled(MethodChannel.Result result, MethodCall call) {
        try {
            // Location settings
            final Integer locationAccuracy = mapFlutterAccuracy.get(call.argument("accuracy"));
            final Long updateIntervalMilliseconds = new Long((int) call.argument("interval"));
            final Long fastestUpdateIntervalMilliseconds = updateIntervalMilliseconds / 2;
            final Float distanceFilter = new Float((double) call.argument("distanceFilter"));

            LocationRequest locationRequest = createLocationRequest(
                    locationAccuracy, updateIntervalMilliseconds, fastestUpdateIntervalMilliseconds, distanceFilter);

            mPluginState.serviceEnabled(result, locationRequest);
        } catch (Exception e) {
            result.error("ENABLE_SERVICE_ERROR",
                    "An unexpected error happened during a call to serviceEnabled:" + e.getMessage(), null);
        }
    }

    private void onRequestService(MethodChannel.Result result, MethodCall call) {
        try {
            // Location settings
            final Integer locationAccuracy = mapFlutterAccuracy.get(call.argument("accuracy"));
            final Long updateIntervalMilliseconds = new Long((int) call.argument("interval"));
            final Long fastestUpdateIntervalMilliseconds = updateIntervalMilliseconds / 2;
            final Float distanceFilter = new Float((double) call.argument("distanceFilter"));

            LocationRequest locationRequest = createLocationRequest(
                    locationAccuracy, updateIntervalMilliseconds, fastestUpdateIntervalMilliseconds, distanceFilter);

            mPluginState.requestService(result, locationRequest);
        } catch (Exception e) {
            result.error("ENABLE_SERVICE_ERROR",
                    "An unexpected error happened during a call to serviceEnabled:" + e.getMessage(), null);
        }
    }

    private void onStartUpdates(MethodChannel.Result result, MethodCall call) {
        try {
            // Location settings
            final Integer locationAccuracy = mapFlutterAccuracy.get(call.argument("accuracy"));
            final Long updateIntervalMilliseconds = new Long((int) call.argument("interval"));
            final Long fastestUpdateIntervalMilliseconds = updateIntervalMilliseconds / 2;
            final Float distanceFilter = new Float((double) call.argument("distanceFilter"));

            LocationRequest locationRequest = createLocationRequest(
                    locationAccuracy, updateIntervalMilliseconds, fastestUpdateIntervalMilliseconds, distanceFilter);

            // Notification Customization
            final String notificationTitle = (String) call.argument("notificationTitle");
            final String notificationBody = (String) call.argument("notificationBody");
            final boolean notificationClickable = (boolean) call.argument("notificationClickable");

            // Label for storing the location data
            final String label = (String) call.argument("label");

            // Settings for location data uploading
            final String url = (String) call.argument("url");
            final HashMap<String, String> authHeader = (HashMap<String, String>) call.argument("header");

            mPluginState.startUpdates(result, locationRequest, notificationTitle, notificationBody,
                    notificationClickable, label, url, authHeader);

        } catch (Exception e) {
            result.error("ENABLE_SERVICE_ERROR",
                    "An unexpected error happened during a call to serviceEnabled:" + e.getMessage(), null);
        }
    }

    private void onStopUpdates(MethodChannel.Result result) {
        mPluginState.stopUpdates(result);
    }

    private void onUpdatesActive(MethodChannel.Result result) {
        mPluginState.updatesActive(result);
    }

    private void onGetLastLocation(MethodChannel.Result result) {
        mPluginState.getLastLocation(result);
    }

    private void onGetLocations(MethodChannel.Result result, MethodCall call) {
        try {
            int n = (int) call.argument("n");
            final List<String> labels = (List<String>) call.argument("labels");

            mPluginState.getLocations(result, labels, n);
        } catch (Exception e) {
            result.error("GET_LOCATIONS_ERROR",
                    "An unexpected error happened while I tried to parse arguments for getting locations from cache:" + e.getMessage(), null);
        }
    }

    private void onDeleteLocations(MethodChannel.Result result, MethodCall call) {
        try {
            // Location settings
            final List<String> labels = (List<String>) call.argument("labels");

            mPluginState.deleteLocations(result, labels);
        } catch (Exception e) {
            result.error("DELETE_LOCATIONS_ERROR",
                    "An unexpected error happened while I tried to parse arguments for deleting locations from cache:" + e.getMessage(), null);
        }
    }

    private void onClearCache(MethodChannel.Result result) {
        mPluginState.clearCache(result);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "hasPermission":
                onHasPermission(result);
                break;
            case "requestPermission":
                onRequestPermission(result);
                break;
            case "serviceEnabled":
                onServiceEnabled(result, call);
                break;
            case "requestService":
                onRequestService(result, call);
                break;
            case "startUpdates":
                onStartUpdates(result, call);
                break;
            case "stopUpdates":
                onStopUpdates(result);
                break;
            case "updatesActive":
                onUpdatesActive(result);
                break;
            case "getLastLocation":
                onGetLastLocation(result);
                break;
            case "getLocations":
                onGetLocations(result, call);
                break;
            case "deleteLocations":
                onDeleteLocations(result, call);
                break;
            case "clearCache":
                onClearCache(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
