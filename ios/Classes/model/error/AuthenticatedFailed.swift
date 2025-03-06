struct AuthenticatedFailed: BaseError {
    var errorCode: Int
    var message: String?

    init(errorCode: Int, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}
