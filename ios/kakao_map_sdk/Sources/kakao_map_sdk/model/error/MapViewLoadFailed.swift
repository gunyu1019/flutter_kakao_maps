struct MapViewLoadFailed: BaseError {
    var errorCode: Int = 0
    var message: String? = "Map Engine creation or initialization failed."
}
