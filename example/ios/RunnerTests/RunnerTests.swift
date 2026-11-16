import Flutter
@testable import kakao_map_sdk
import KakaoMapsSDK
import XCTest

final class RunnerTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        // Use a placeholder key: lifecycle tests do not require successful map authentication.
        SDKInitializer.InitSDK(appKey: "native-lifecycle-test-placeholder")
    }

    func testViewDeinitNotifiesRunningEngine() {
        let engine = TestFlutterEngine(name: "view-deinit-running")
        let messenger = RecordingMessenger()
        var view: KakaoMapView? = makeView(engine: engine, messenger: messenger)
        weak var weakView = view

        view = nil

        XCTAssertNil(weakView)
        XCTAssertEqual(messenger.methods.filter { $0 == "onMapDestroy" }, ["onMapDestroy"])
    }

    func testViewDeinitDoesNotNotifyStoppedEngine() {
        let engine = TestFlutterEngine(name: "view-deinit-stopped")
        let messenger = RecordingMessenger()
        var view: KakaoMapView? = makeView(engine: engine, messenger: messenger)
        weak var weakView = view
        engine.runningIsolateId = nil

        view = nil

        XCTAssertNil(weakView)
        XCTAssertFalse(messenger.methods.contains("onMapDestroy"))
    }

    func testMapRemovalNotifiesRunningEngineExactlyOnce() {
        let engine = TestFlutterEngine(name: "map-removal")
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)

        controller.onMapDestroy()
        controller.onMapDestroy()

        XCTAssertEqual(messenger.methods, ["onMapDestroy"])
    }

    func testDestroyContextSuppressesNotificationWhileEngineStillExists() {
        let engine = TestFlutterEngine(name: "context-destroyed")
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)
        engine.runningIsolateId = nil

        controller.onMapDestroy()

        XCTAssertTrue(messenger.methods.isEmpty)
        withExtendedLifetime(engine) {}
    }

    func testControllerDoesNotKeepEngineAlive() {
        var engine: TestFlutterEngine? = TestFlutterEngine(name: "engine-released")
        weak var weakEngine = engine
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)
        engine = nil

        XCTAssertNil(weakEngine)
        controller.onMapDestroy()
        XCTAssertTrue(messenger.methods.isEmpty)
    }

    func testRunningHeadlessEngineStillReceivesNotification() {
        let engine = TestFlutterEngine(name: "headless")
        XCTAssertNil(engine.viewController)
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)

        controller.onMapDestroy()

        XCTAssertEqual(messenger.methods, ["onMapDestroy"])
    }

    func testFinishThenMapRemovalDoesNotDuplicateNotification() {
        let engine = TestFlutterEngine(name: "finish")
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)
        var completed = false

        controller.finish { _ in completed = true }
        controller.onMapDestroy()

        XCTAssertTrue(completed)
        XCTAssertEqual(messenger.methods, ["onMapDestroy"])
    }

    func testStoppingOneEngineDoesNotSuppressAnotherEnginesNotification() {
        let stoppedEngine = TestFlutterEngine(name: "stopped")
        let runningEngine = TestFlutterEngine(name: "running")
        let stoppedMessenger = RecordingMessenger()
        let runningMessenger = RecordingMessenger()
        let stoppedController = makeController(engine: stoppedEngine, messenger: stoppedMessenger)
        let runningController = makeController(engine: runningEngine, messenger: runningMessenger)
        stoppedEngine.runningIsolateId = nil

        stoppedController.onMapDestroy()
        runningController.onMapDestroy()

        XCTAssertTrue(stoppedMessenger.methods.isEmpty)
        XCTAssertEqual(runningMessenger.methods, ["onMapDestroy"])
    }

    func testActualDestroyedFlutterContextDoesNotReceiveMessage() {
        let engine = FlutterEngine(name: "actual-destroyed-context")
        let messenger = RecordingMessenger()
        let controller = makeController(engine: engine, messenger: messenger)
        engine.destroyContext()

        controller.onMapDestroy()
        XCTAssertTrue(messenger.methods.isEmpty)
        withExtendedLifetime(engine) {}
    }

    private func makeController(engine: FlutterEngine?, messenger: FlutterBinaryMessenger) -> KakaoMapController {
        KakaoMapController(
            channel: FlutterMethodChannel(name: "test/map", binaryMessenger: messenger),
            overlayChannel: FlutterMethodChannel(name: "test/overlay", binaryMessenger: messenger),
            mapController: KMController(viewContainer: KMViewContainer()),
            flutterEngine: engine
        )
    }

    private func makeView(engine: FlutterEngine, messenger: FlutterBinaryMessenger) -> KakaoMapView {
        KakaoMapView(
            frame: .zero,
            channel: FlutterMethodChannel(name: "test/view", binaryMessenger: messenger),
            overlayChannel: FlutterMethodChannel(name: "test/view-overlay", binaryMessenger: messenger),
            option: MapviewInfo(
                viewName: "test-map",
                appName: "openmap",
                viewInfoName: "map",
                defaultPosition: MapPoint(longitude: 127, latitude: 37),
                defaultLevel: 15
            ),
            flutterEngine: engine
        )
    }
}

/// Control the public running-state property without starting Dart or authenticating a map.
private final class TestFlutterEngine: FlutterEngine {
    var runningIsolateId: String? = "test-isolate"

    override var isolateId: String? {
        runningIsolateId
    }
}

private final class RecordingMessenger: NSObject, FlutterBinaryMessenger {
    private(set) var methods: [String] = []

    func send(onChannel channel: String, message: Data?) {
        send(onChannel: channel, message: message, binaryReply: nil)
    }

    func send(onChannel _: String, message: Data?, binaryReply _: FlutterBinaryReply?) {
        if let message {
            methods.append(FlutterStandardMethodCodec.sharedInstance().decodeMethodCall(message).method)
        }
    }

    func setMessageHandlerOnChannel(_: String, binaryMessageHandler _: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
        1
    }

    func cleanUpConnection(_: FlutterBinaryMessengerConnection) {}
}
