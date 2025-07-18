func asBool(_ v: Any) -> Bool {
    v as! Bool
}

func asFloat(_ v: Any) -> Float {
    v as! Float
}

func asDouble(_ v: Any) -> Double {
    v as! Double
}

func asInt(_ v: Any) -> Int {
    v as! Int
}

func asUInt(_ v: Any) -> UInt {
    v as! UInt
}

func asString(_ v: Any) -> String {
    v as! String
}

func asDict(_ v: Any) -> [String: Any] {
    v as! [String: Any]
}

func asDictTyped<T>(_ v: Any, caster: (Any) throws -> T) -> [String: T] {
    let dict = asDict(v)
    var newDict: [String: T] = [:]
    for (k, v) in dict {
        newDict[k] = try! caster(v)
    }
    return newDict
}

func asArray(_ v: Any) -> [Any] {
    return v as! [Any]
}

func asArray<T>(_ v: Any, caster: (Any) throws -> T) -> [T] {
    let list = asArray(v)
    return try! list.map(caster)
}

func castSafty<T>(_ v: Any?, caster: (Any) throws -> T) -> T? {
    if v == nil || v is NSNull {
        return nil
    } else {
        return try! caster(v!)
    }
}
