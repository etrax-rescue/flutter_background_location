package at.etrax.background_location;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;

/**
 * LocationPlugin
 */
public class BackgroundLocationPlugin implements FlutterPlugin, ActivityAware {

    private static final String TAG = "BackgroundLocationPlugin";

    private MethodCallHandlerImpl methodCallHandler;
    private StreamHandlerImpl streamHandler;

    @Nullable
    private PluginState mPluginState;

    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onAttachedToEngine called");
        pluginBinding = binding;

        mPluginState = new PluginState(binding.getApplicationContext(), /* activity= */ null);
        methodCallHandler = new MethodCallHandlerImpl(mPluginState);
        methodCallHandler.startListening(binding.getBinaryMessenger());

        streamHandler = new StreamHandlerImpl(mPluginState);
        streamHandler.startListening(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = null;

        if (methodCallHandler != null) {
            methodCallHandler.stopListening();
            methodCallHandler = null;
        }

        if (streamHandler != null) {
            streamHandler.stopListening();
            streamHandler = null;
        }

        mPluginState = null;
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mPluginState.setActivity(binding.getActivity());

        activityBinding = binding;
        setup(pluginBinding.getBinaryMessenger(), activityBinding.getActivity());//, null);
    }

    @Override
    public void onDetachedFromActivity() {
        tearDown();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        tearDown();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    private void setup(final BinaryMessenger messenger, final Activity activity) {
        activityBinding.addActivityResultListener(mPluginState);
        activityBinding.addRequestPermissionsResultListener(mPluginState);
    }

    private void tearDown() {
        activityBinding.removeActivityResultListener(mPluginState);
        activityBinding.removeRequestPermissionsResultListener(mPluginState);
        activityBinding = null;
    }
}
