package at.etrax.background_location;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.Observer;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import at.etrax.background_location.database.Converters;
import at.etrax.background_location.database.LocationDao;
import at.etrax.background_location.database.LocationData;
import at.etrax.background_location.database.LocationDatabase;
import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class PluginState implements PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

    private static final String TAG = "PluginState";

    private final Context mApplicationContext;

    public Activity mActivity;

    //private LocationManager mLocationManager;
    private SettingsClient mSettingsClient;

    // The fused location provider client which we'll use to get the current location
    private FusedLocationProviderClient mFusedLocationClient;

    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;
    private static final int SERVICES_ENABLE_REQUEST_CODE = 0x1001;

    private MethodChannel.Result permissionResult;
    private MethodChannel.Result servicesResult;

    private boolean initializeUpdates = false;

    private Bundle mStartUpdatesBundle;

    private LocationDatabase db;

    private Observer<LocationData> mLocationObserver;

    private Handler mHandler;

    PluginState(Context applicationContext, Activity activity) {
        mApplicationContext = applicationContext;

        db = LocationDatabase.getDatabase(mApplicationContext);

        mHandler = new Handler(mApplicationContext.getMainLooper());

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(mApplicationContext);

        setActivity(activity);
    }

    void setActivity(Activity activity) {
        mActivity = activity;
        if (activity != null) {
            //mLocationManager = (LocationManager) mActivity.getSystemService(Context.LOCATION_SERVICE);
            mSettingsClient = (SettingsClient) LocationServices.getSettingsClient(mActivity);
        } else {
            //mLocationManager = null;
            mSettingsClient = null;
        }
    }

    //============================================================================================//
    //<editor-fold desc="Location Permission Methods">

    /**
     * @param result
     */
    boolean hasPermission(final MethodChannel.Result result) {
        if(mActivity == null) {
            result.error("PERMISSION_STATUS_ERROR",
                    "Activity is not set",
                    null);
            return false;
        }
        // First check if we can access fine location
        boolean fineLocationApproved = ActivityCompat.checkSelfPermission(mActivity,
                Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;

        boolean backgroundLocationApproved = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            backgroundLocationApproved = ActivityCompat.checkSelfPermission(mActivity,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED;
        }

        boolean granted = fineLocationApproved && backgroundLocationApproved;
        if (result != null) {
            result.success(granted ? 1 : 0);
        }
        return granted;
    }

    /**
     * @param result
     */
    void requestPermission(final MethodChannel.Result result) {
        if(mActivity == null) {
            result.error("PERMISSION_STATUS_ERROR",
                    "Activity is not set",
                    null);
            return;
        }
        boolean fineLocationApproved = ActivityCompat.checkSelfPermission(mActivity,
                Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
        boolean backgroundLocationApproved = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            backgroundLocationApproved = ActivityCompat.checkSelfPermission(mActivity,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED;
        }
        if(fineLocationApproved && backgroundLocationApproved) {
            // The permission is already granted
            result.success(1);
        } else {
            // The permission is not granted yet. Ask for it.
            if (mActivity != null) {
                String[] permissions;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    permissions = new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION};
                } else {
                    permissions = new String[]{Manifest.permission.ACCESS_FINE_LOCATION};
                }
                permissionResult = result;
                ActivityCompat.requestPermissions(mActivity, permissions,
                        REQUEST_PERMISSIONS_REQUEST_CODE);
            }
        }
    }

    /**
     * @param requestCode
     * @param permissions
     * @param grantResults
     * @return
     */
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if(requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
            if(grantResults.length <= 0) {
                permissionResult.error("ERROR_REQUESTING_PERMISSIONS", "The permission request was cancelled", null);
            } else {
                boolean fineLocationApproved = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                boolean backgroundLocationApproved = true;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    backgroundLocationApproved = grantResults[1] == PackageManager.PERMISSION_GRANTED;
                }
                if(fineLocationApproved && backgroundLocationApproved) {
                    // The user granted the permission. Continue to next step.
                    permissionResult.success(1);
                } else {
                    // The user denied the permission. Ideally the application implementing this plugin should show an educational UI.
                    permissionResult.success(0);
                }
            }
            permissionResult = null;
            return true;
        }
        return false;
    }
    //</editor-fold>

    //============================================================================================//
    //<editor-fold desc="Location Services Methods">

    /**
     * @param result
     */
    void serviceEnabled(final MethodChannel.Result result, final LocationRequest locationRequest) {
        if (mActivity == null) {
            result.error("SERVICE_STATUS_ERROR",
                    "Activity is not set",
                    null);
            initializeUpdates = false;
            return;
        }

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(locationRequest);
        LocationSettingsRequest locationSettingsRequest = builder.build();

        Task<LocationSettingsResponse> task = mSettingsClient.checkLocationSettings(locationSettingsRequest);
        task.addOnCompleteListener(new OnCompleteListener<LocationSettingsResponse>() {
            @Override
            public void onComplete(Task<LocationSettingsResponse> task) {
                try {
                    LocationSettingsResponse response = task.getResult(ApiException.class);
                    // All location settings are satisfied.
                    if (initializeUpdates) {
                        launchBackgroundService(result);
                    } else {
                        result.success(1);
                    }
                } catch (ApiException exception) {
                    // Location settings are not satisfied.
                    result.success(0);
                    initializeUpdates = false;
                }
            }
        });
    }

    /**
     * @param result
     * @param locationRequest
     */
    void requestService(final MethodChannel.Result result, final LocationRequest locationRequest) {
        if (mActivity == null) {
            result.error("SERVICE_STATUS_ERROR",
                    "Activity is not set",
                    null);
            return;
        }

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(locationRequest);
        LocationSettingsRequest locationSettingsRequest = builder.build();

        Task<LocationSettingsResponse> task = mSettingsClient.checkLocationSettings(locationSettingsRequest);
        task.addOnCompleteListener(new OnCompleteListener<LocationSettingsResponse>() {
            @Override
            public void onComplete(Task<LocationSettingsResponse> task) {
                try {
                    LocationSettingsResponse response = task.getResult(ApiException.class);
                    // All location settings are satisfied.
                    result.success(1);
                } catch (ApiException exception) {
                    switch (exception.getStatusCode()) {
                        case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                            // Location settings are not satisfied. But could be fixed by showing the
                            // user a dialog.
                            try {
                                // Cast to a resolvable exception.
                                ResolvableApiException resolvable = (ResolvableApiException) exception;
                                servicesResult = result;
                                // Show the dialog by calling startResolutionForResult(),
                                // and check the result in onActivityResult().
                                resolvable.startResolutionForResult(mActivity, SERVICES_ENABLE_REQUEST_CODE);

                            } catch (IntentSender.SendIntentException | ClassCastException e) {
                                result.error("SERVICE_STATUS_ERROR",
                                        "Could not resolve location request",
                                        e.getStackTrace());
                            }

                            break;
                        case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                            // Location settings are not satisfied. However, we have no way to fix the
                            // settings so we won't show the dialog.
                            result.error("SERVICE_STATUS_DISABLED",
                                    "Failed to get background_location. Location services disabled",
                                    null);
                            break;
                    }
                }
            }
        });
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == SERVICES_ENABLE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                // Location settings were successfully activated.
                servicesResult.success(1);
            } else {
                // User dismissed location update prompt.
                servicesResult.success(0);
            }
            servicesResult = null;
        }
        return true;
    }
    //</editor-fold>

    //============================================================================================//
    //<editor-fold desc="Start Location Updates Methods">

    void launchBackgroundService(MethodChannel.Result result) {
        // Starting the background service
        Intent intent = new Intent(mApplicationContext, BackgroundService.class);
        intent.setAction(BackgroundService.ACTION_START_UPDATES);
        intent.putExtras(mStartUpdatesBundle);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mApplicationContext.startForegroundService(intent);
        } else {
            mApplicationContext.startService(intent);
        }
        initializeUpdates = false;
        result.success(1);
    }

    void updatesActive(final MethodChannel.Result result) {
        if(BackgroundService.isRunning()) {
            result.success(1);
        } else {
            result.success(0);
        }
    }

    /**
     * Starts the location update service. First the location permission is checked, and then the
     * current services status is checked as well. When one of those requirements is not met,
     * the location update service will not be started, and the result will be 0.
     * @param result
     */
    void startUpdates(final MethodChannel.Result result,
                      LocationRequest locationRequest,
                      String notificationTitle,
                      String notificationBody,
                      Boolean notificationClickable,
                      String label,
                      String sendUrl,
                      HashMap<String,String> header) {
        Log.d(TAG, "startUpdates");

        if (mApplicationContext == null) {
            result.success(0);
            return;
        }

        Bundle bundle = new Bundle();
        bundle.putParcelable("locationRequest", locationRequest);

        bundle.putString("notificationTitle", notificationTitle);
        bundle.putString("notificationBody", notificationBody);
        bundle.putBoolean("notificationClickable", notificationClickable);

        bundle.putString("label", label);

        bundle.putString("url", sendUrl);
        bundle.putSerializable("header", header);
        if(mActivity != null) {
            bundle.putString("activityClassName", mActivity.getClass().getCanonicalName());
        }

        if (!hasPermission(null)) {
            // Permission is not granted
            result.success(0);
            return;
        }
        mStartUpdatesBundle = bundle;
        initializeUpdates = true;
        serviceEnabled(result, locationRequest);
    }

    /**
     * Stops the location updates service.
     * @param result
     */
    void stopUpdates(final MethodChannel.Result result) {
        Log.d(TAG, "stopUpdates");
        Intent intent = new Intent(mApplicationContext, BackgroundService.class);
        intent.setAction(BackgroundService.ACTION_STOP_UPDATES);
        mApplicationContext.startService(intent);

        result.success(1);
    }
    //</editor-fold>

    //============================================================================================//
    //<editor-fold desc="Database interfacing Methods">

    /**
     * Connects the event sink stream to the live data coming from the location database.
     * @param eventsSink
     */
    void registerStream(final EventChannel.EventSink eventsSink, final String label) {
        mLocationObserver = new Observer<LocationData>() {
            @Override
            public void onChanged(LocationData locationData) {
                if (locationData != null) {
                    HashMap<String, Object> loc = Converters.convertLocationDataToHashMap(locationData);
                    if (eventsSink != null) {
                        eventsSink.success(loc);
                    }
                }
            }
        };
        if(label.equals("")) {
            db.locationDao().streamLocation().observeForever(mLocationObserver);
        } else {
            db.locationDao().streamLocationWithLabel(label).observeForever(mLocationObserver);
        }
    }

    /**
     * Disconnects the event sink stream from the live data.
     */
    void deregisterStream() {
        db.locationDao().streamLocation().removeObserver(mLocationObserver);
        mLocationObserver = null;
    }

    void getLastLocation(final MethodChannel.Result result) {
        mFusedLocationClient.getLastLocation().addOnCompleteListener(new OnCompleteListener<Location>() {
            @Override
            public void onComplete(@NonNull Task<Location> task) {
                if (task.isSuccessful()) {
                    final Location location = task.getResult();
                    if(location != null) {
                        result.success(Converters.convertLocationToHashMap(location));
                        return;
                    }
                }
                LocationDatabase.databaseExecutor.execute(new Runnable() {
                    @Override
                    public void run() {
                        final LocationData locationData = db.locationDao().getLastLocation();
                        Runnable sendRunnable = new Runnable() {
                            @Override
                            public void run() {
                                if (locationData == null) {
                                    result.success(new HashMap<String, Object>());
                                } else {
                                    result.success(Converters.convertLocationDataToHashMap(locationData));
                                }
                            }
                        };
                        mHandler.post(sendRunnable);
                    }
                });


            }
        });
    }



    void getLocations(final MethodChannel.Result result, final List<String> labels, final int n) {
        LocationDatabase.databaseExecutor.execute(new Runnable() {
            @Override
            public void run() {
                List<LocationData> locationDataList;
                if(n < 0) {
                    locationDataList = db.locationDao().getLocations(labels);
                } else {
                    locationDataList = db.locationDao().getNLocations(labels, n);
                }
                if(locationDataList.size() > 0) {
                    final List<HashMap<String, Object>> locationList = new LinkedList<>();
                    for (LocationData locationData : locationDataList) {
                        locationList.add(Converters.convertLocationDataToHashMap(locationData));
                    }

                    Runnable sendRunnable = new Runnable() {
                        @Override
                        public void run() {
                            result.success(locationList);
                        }
                    };
                    mHandler.post(sendRunnable);
                } else {
                    Log.d(TAG, "No locations corresponding to the given labels were found");
                    Runnable sendRunnable = new Runnable() {
                        @Override
                        public void run() {
                            result.success(new LinkedList<HashMap<String, Object>>() {});
                        }
                    };
                    mHandler.post(sendRunnable);
                }
            }
        });
    }

    void clearCache(final MethodChannel.Result result) {
        LocationDatabase.databaseExecutor.execute(new Runnable() {
            @Override
            public void run() {
                db.locationDao().deleteAll();

                Runnable sendRunnable = new Runnable() {
                    @Override
                    public void run() {
                        result.success(1);
                    }
                };
                mHandler.post(sendRunnable);
            }
        });
    }

    void deleteLocations(final MethodChannel.Result result, final List<String> labels) {
        LocationDatabase.databaseExecutor.execute(new Runnable() {
            @Override
            public void run() {
                db.locationDao().deleteLocations(labels);
                Runnable sendRunnable = new Runnable() {
                    @Override
                    public void run() {
                        result.success(1);
                    }
                };
                mHandler.post(sendRunnable);
            }
        });
    }
    //</editor-fold>
}
