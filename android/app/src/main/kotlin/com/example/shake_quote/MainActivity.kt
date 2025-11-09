package com.example.shake_quote


import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity: FlutterActivity(), SensorEventListener {

    private val SHAKE_CHANNEL = "com.example.shake_quote/shake"
    private val CONTROL_CHANNEL = "com.example.shake_quote/control"

    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var shakeEventSink: EventChannel.EventSink? = null

    private var lastShakeTime = 0L
    private val SHAKE_THRESHOLD = 12f  // Adjust sensitivity

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup EventChannel → Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SHAKE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    shakeEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    shakeEventSink = null
                }
            })

        // Setup MethodChannel → From Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTROL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startShakeDetection" -> {
                        startShakeDetection()
                        result.success("Shake detection started")
                    }
                    "stopShakeDetection" -> {
                        stopShakeDetection()
                        result.success("Shake detection stopped")
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startShakeDetection() {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        accelerometer?.also { sensor ->
            sensorManager?.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
        }
    }

    private fun stopShakeDetection() {
        sensorManager?.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_ACCELEROMETER) {
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            val acceleration = sqrt((x * x + y * y + z * z).toDouble()).toFloat() - SensorManager.GRAVITY_EARTH

            val currentTime = System.currentTimeMillis()
            if (acceleration > SHAKE_THRESHOLD) {
                if (currentTime - lastShakeTime > 1000) {
                    lastShakeTime = currentTime
                    shakeEventSink?.success("onShakeDetected")
                }
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
