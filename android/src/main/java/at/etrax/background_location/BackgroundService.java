package at.etrax.background_location;

import android.annotation.TargetApi;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.location.OnNmeaMessageListener;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Looper;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.TaskStackBuilder;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.HttpURLConnection;

import at.etrax.background_location.database.LocationDao;
import at.etrax.background_location.database.LocationData;
import at.etrax.background_location.database.LocationDatabase;
import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;

import static at.etrax.background_location.database.Converters.convertLocationToLocationData;

public class BackgroundService extends Service {
    private static final String TAG = "BackgroundLocationService";

    static final String ACTION_START_UPDATES = "start_updates";
    static final String ACTION_STOP_UPDATES = "stop_updates";

    // The fused location provider client
    private FusedLocationProviderClient mFusedLocationClient;

    // The location callback
    private LocationCallback mLocationCallback;

    // The location request
    private LocationRequest mLocationRequest;

    // static variable used to check whether the service is running.
    private static boolean running = false;

    private String mLabel = "";
    private String mUrl;
    private HashMap<String, String> mHeader;

    // The notification builder
    private NotificationCompat.Builder mNotificationBuilder;

    // Since Android Nougat we can receive NMEA data from the GNSS
    @TargetApi(Build.VERSION_CODES.N)
    private OnNmeaMessageListener mMessageListener;

    private EventChannel.EventSink events;

    private Double mLastMslAltitude;

    private RequestQueue mRequestQueue;

    private LocationDatabase db;
    private LocationDao locationDao;

    /**
     *
     */
    @Override
    public void onCreate() {
        super.onCreate();

        Log.d(TAG, "onCreate service");

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
        mRequestQueue = Volley.newRequestQueue(this);

        db = LocationDatabase.getDatabase(getApplicationContext());
        locationDao = db.locationDao();

        createLocationCallback();

        // Updates Notification
        String UPDATES_CHANNEL_ID = "background_location_updates_channel";
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationChannel channel = new NotificationChannel(UPDATES_CHANNEL_ID, "Location Updates Notification",
                    NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
        mNotificationBuilder = new NotificationCompat.Builder(this, UPDATES_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_gps_fixed)
                .setPriority(NotificationCompat.PRIORITY_LOW);
    }

    /**
     *
     * @param intent
     * @param flags
     * @param startId
     * @return
     */
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        if (ACTION_START_UPDATES.equals(intent.getAction())){
            Bundle bundle = intent.getExtras();
            try {
                mLocationRequest = (LocationRequest) bundle.getParcelable("locationRequest");
            } catch (NullPointerException e) {
                mLocationRequest = null;
            }
            if(mLocationRequest != null) {
                final String notificationTitle = bundle.getString("notificationTitle","");
                final String notificationBody = bundle.getString("notificationBody","");
                final boolean notificationClickable = bundle.getBoolean("notificationClickable", false);
                final String activityClassName = bundle.getString("activityClassName", "");

                updateNotification(notificationTitle, notificationBody, notificationClickable, activityClassName);

                mLabel = bundle.getString("label", "");
                mUrl = bundle.getString("url", "");
                if(bundle.getSerializable("header") instanceof HashMap) {
                    try {
                        mHeader = (HashMap<String, String>) bundle.getSerializable("header");
                    } catch (ClassCastException e) {
                        Log.e(TAG, e.getMessage());
                    }
                } else {
                    mHeader = new HashMap<String, String>(){};
                }

                startForeground(102, mNotificationBuilder.build());
                startLocationUpdates(mLocationRequest);
            }
        } else if (ACTION_STOP_UPDATES.equals(intent.getAction())){
            // Remove the notification
            stopForeground(true);
            // Stop the location updates
            stopLocationUpdates();
            // Cancel requests
            cancelRequests();
            // Stop the service itself
            stopSelf();
        }
        return START_STICKY;
    }

    /**
     * This service doesn't provide binding, so onBind always returns null.
     * @param intent
     * @return
     */
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    /**
     * Returns whether location updates are active or not.
     * @return
     */
    public static boolean isRunning() {
        return running;
    }

    /**
     * Start the location updates with the settings provided by the LocationRequest
     * @param locationRequest
     */
    private void startLocationUpdates(LocationRequest locationRequest) {
        running = true;
        mFusedLocationClient.requestLocationUpdates(locationRequest,
                mLocationCallback,
                Looper.getMainLooper());
    }

    /**
     * Stop the location updates
     */
    private void stopLocationUpdates() {
        mFusedLocationClient.removeLocationUpdates(mLocationCallback);
        running = false;
    }

    private void cancelRequests() {
        if (mRequestQueue != null) {
            mRequestQueue.cancelAll(TAG);
        }
    }

    /**
     * Update the notification
     * @param notificationTitle
     * @param notificationBody
     * @param notificationClickable
     */
    private void updateNotification(String notificationTitle, String notificationBody, boolean notificationClickable, String activityClassName) {
        if(!notificationTitle.equals("")) {
            mNotificationBuilder.setContentTitle(notificationTitle);
        }
        if(!notificationBody.equals("")) {
            mNotificationBuilder.setContentText(notificationBody);
        }

        if (notificationClickable) {
            try {
                // Try to get the class associated with the activity class name
                Class<?> activityClass = (Class<?>) Class.forName(activityClassName);
                // Create an Intent for the activity we want to start
                Intent resultIntent = new Intent(getApplicationContext(), activityClass);
                // Create the TaskStackBuilder and add the intent, which inflates the back stack
                TaskStackBuilder stackBuilder = TaskStackBuilder.create(getApplicationContext());
                stackBuilder.addNextIntentWithParentStack(resultIntent);
                // Get the PendingIntent containing the entire back stack
                PendingIntent resultPendingIntent =
                        stackBuilder.getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);
                mNotificationBuilder.setContentIntent(resultPendingIntent);
            } catch (ClassNotFoundException e) {
                Log.e(TAG, e.getMessage());
            }
        }
    }

    /**
     *
     * @param locationResult
     */
    void onLocationUpdate(LocationResult locationResult) {
        Log.d(TAG, "Location update received!");
        List<LocationData> locationList = new ArrayList<>(locationResult.getLocations().size());
        for (Location location:locationResult.getLocations()) {
            locationList.add(convertLocationToLocationData(location, mLastMslAltitude, mLabel));
        }

        // Convert the Arraylist to an array (giving it an initial length of 0 seems to improve performance according to some sources)
        final LocationData[] locations = locationList.toArray(new LocationData[0]);
        // Insert the location data into the database. Ensure that this is done on a background thread by using the executor.
        LocationDatabase.databaseExecutor.execute(new Runnable() {
            @Override
            public void run() {
                locationDao.bulkInsert(locations);
            }
        });

        // First cancel all pending requests so that nothing gets sent twice
        cancelRequests();

        // Then retrieve the location data that was not already uploaded from the db
        // TODO: get location data that is not already uploaded and has the right label.
        if(!mUrl.equals("")) {
            LocationDatabase.databaseExecutor.execute(new Runnable() {
                @Override
                public void run() {
                    List<LocationData> locationDataList = locationDao.getLocationsForUpload(mLabel);
                    // dispatchRequest
                    dispatchRequest(mUrl, locationDataList, mHeader);
                }
            });
        }
    }

    void dispatchRequest(String url, final List<LocationData> locationDataList, final HashMap<String, String> header) {
        // Convert the retrieved data into a JSONArray and then into a string.
        Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation().setPrettyPrinting().serializeNulls().create();
        final String requestBody = gson.toJson(locationDataList);

        // Create a new request with this data and send it
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, null, null) {
            @Override
            protected Response<String> parseNetworkResponse(NetworkResponse response) {
                Response<String> parsedResponse = super.parseNetworkResponse(response);
                if(response.statusCode == HttpURLConnection.HTTP_CREATED) {
                    for(LocationData locationData:locationDataList) {
                        locationData.uploaded = true;
                    }
                    LocationDatabase.databaseExecutor.execute(new Runnable() {
                        @Override
                        public void run() {
                            final LocationData[] locations = locationDataList.toArray(new LocationData[0]);
                            locationDao.updateLocations(locations);
                        }
                    });
                }
                return parsedResponse;
            }

            @Override
            public byte[] getBody() throws AuthFailureError {
                return requestBody == null ? null : requestBody.getBytes(StandardCharsets.UTF_8);
            }

            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String, String> modifiedHeader = header;
                modifiedHeader.put("content-type", "application/json");
                return modifiedHeader;
            }
        };
        // Define a retry policy for the request
        //stringRequest.setRetryPolicy(new DefaultRetryPolicy(DefaultRetryPolicy.DEFAULT_TIMEOUT_MS,
        //        DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        // Mark the request with a TAG so that we can later cancel it.
        stringRequest.setTag(TAG);
        // Add the request to the RequestQueue.
        mRequestQueue.add(stringRequest);
    }

    /**
     * Creates a callback for receiving background_location events.
     */
    private void createLocationCallback() {
        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onLocationUpdate(locationResult);
            }
        };

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mMessageListener = new OnNmeaMessageListener() {
                @Override
                public void onNmeaMessage(String message, long timestamp) {
                    if (message.startsWith("$")) {
                        String[] tokens = message.split(",");
                        String type = tokens[0];

                        // Parse altitude above sea level, Detailed description of NMEA string here
                        // http://aprs.gids.nl/nmea/#gga
                        if (type.startsWith("$GPGGA") && tokens.length > 9) {
                            if (!tokens[9].isEmpty()) {
                                mLastMslAltitude = Double.parseDouble(tokens[9]);
                            }
                        }
                    }
                }
            };
        }
    }
}
