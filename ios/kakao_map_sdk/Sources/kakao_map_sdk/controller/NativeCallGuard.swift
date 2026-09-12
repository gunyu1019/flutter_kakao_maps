import Flutter

func invalidNativeCall(method: String, reason: String) -> FlutterError {
    FlutterError(
        code: "INVALID_NATIVE_CALL",
        message: "Failed to handle native method '\(method)': \(reason)",
        details: ["method": method]
    )
}

func missingNativeResource(method: String, resource: String, id: String?) -> FlutterError {
    invalidNativeCall(
        method: method,
        reason: "No \(resource) exists for ID '\(id ?? "<missing>")'."
    )
}
