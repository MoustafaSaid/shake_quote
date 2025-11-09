import UIKit
import Flutter
import CoreMotion

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let shakeChannelName = "com.example.shakequote/shake"
    private let controlChannelName = "com.example.shakequote/control"

    private var eventSink: FlutterEventSink?
    private let motionManager = CMMotionManager()
    private var isShakeDetectionActive = false

    private var lastShakeTime = Date().timeIntervalSince1970
    private let shakeThreshold: Double = 2.5  // Adjust for sensitivity

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        // Setup EventChannel (Native → Flutter)
        let eventChannel = FlutterEventChannel(name: shakeChannelName, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(self)

        // Setup MethodChannel (Flutter → Native)
        let methodChannel = FlutterMethodChannel(name: controlChannelName, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }

            switch call.method {
            case "startShakeDetection":
                self.startShakeDetection()
                result("Shake detection started")
            case "stopShakeDetection":
                self.stopShakeDetection()
                result("Shake detection stopped")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Shake Detection Logic
    private func startShakeDetection() {
        if isShakeDetectionActive { return }
        isShakeDetectionActive = true

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let acceleration = data?.acceleration else { return }

                let gX = acceleration.x
                let gY = acceleration.y
                let gZ = acceleration.z

                let totalAcceleration = sqrt(gX * gX + gY * gY + gZ * gZ)

                let currentTime = Date().timeIntervalSince1970
                if totalAcceleration > self.shakeThreshold {
                    if currentTime - self.lastShakeTime > 1.0 {
                        self.lastShakeTime = currentTime
                        self.eventSink?("onShakeDetected")
                    }
                }
            }
        }
    }

    private func stopShakeDetection() {
        if !isShakeDetectionActive { return }
        motionManager.stopAccelerometerUpdates()
        isShakeDetectionActive = false
    }
}

// MARK: - Event Channel Stream Handler
extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        stopShakeDetection()
        return nil
    }
}
