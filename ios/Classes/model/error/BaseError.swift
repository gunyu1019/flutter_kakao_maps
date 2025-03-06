protocol BaseError: Error {
    var errorCode: Int { get }
    var message: String? { get }
}
