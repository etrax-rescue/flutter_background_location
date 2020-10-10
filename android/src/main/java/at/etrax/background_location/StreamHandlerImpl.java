package at.etrax.background_location;

import android.content.Intent;
import android.util.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;

class StreamHandlerImpl implements StreamHandler {
    private static final String TAG = "StreamHandlerImpl";

    private final PluginState mPluginState;
    private EventChannel channel;

    private static final String STREAM_CHANNEL_NAME = "at.etrax.background_location/event";

    StreamHandlerImpl(PluginState state) {
        mPluginState = state;
    }

    /**
     * Registers this instance as a stream events handler on the given
     * {@code messenger}.
     */
    void startListening(BinaryMessenger messenger) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.");
            stopListening();
        }

        channel = new EventChannel(messenger, STREAM_CHANNEL_NAME);
        channel.setStreamHandler(this);
    }

    /**
     * Clears this instance from listening to stream events.
     */
    void stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.");
            return;
        }

        channel.setStreamHandler(null);
        channel = null;
    }

    @Override
    public void onListen(Object arguments, final EventSink eventsSink) {
        try {
            String label = (String) arguments;
            mPluginState.registerStream(eventsSink, label);
        } catch (ClassCastException e) {
            Log.d(TAG, "Wrong argument type for Broadcast Stream");
        }
    }

    @Override
    public void onCancel(Object arguments) {
        mPluginState.deregisterStream();
    }

}
