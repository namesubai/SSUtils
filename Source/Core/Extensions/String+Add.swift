//
//  String+.swift
//  
//
//  Created by yangsq on 2020/11/19.
//

import Foundation
import CommonCrypto

public extension String {
    
    enum CryptoAlgorithm {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
        
        var HMACAlgorithm: CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:      result = kCCHmacAlgMD5
            case .SHA1:     result = kCCHmacAlgSHA1
            case .SHA224:   result = kCCHmacAlgSHA224
            case .SHA256:   result = kCCHmacAlgSHA256
            case .SHA384:   result = kCCHmacAlgSHA384
            case .SHA512:   result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }
        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }

    
//    func md5(secret: String) -> String {
//
//        let cKey = secret.cString(using: .utf8)
//        let cData = self.data(using: .utf8)
////        let data =
//
//        let digest_len = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digest_len)
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), cKey, strlen(cKey!), cData, strlen(cData!), result)
//        let str = NSMutableString()
//        for i in 0..<digest_len {
//            str.appendFormat("%02x", result[i])
//        }
//        result.deallocate()
//        return str as String
//    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let strData = self.data(using: .utf8)
        let strDataLen = strData!.count

//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, strData!.bytes, strDataLen, result)
        let digest = stringFromResult(result: result, length: digestLen)
        result.deallocate()
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
            let hash = NSMutableString()
            for i in 0..<length {
                hash.appendFormat("%02x", result[i])
            }
            return String(hash)
        }


}


public extension String {
    func size(of size: CGSize, font: UIFont) -> CGSize {
        let str = self as NSString
        return str.boundingRect(with: size, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).size
    }
}

public extension String {
    static let randomStrCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len: Int) -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(randomStrCharacters.count)))
            ranStr.append(randomStrCharacters[randomStrCharacters.index(randomStrCharacters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    
    /// 随机字符
    /// - Parameter length: length description
    /// - Returns: description
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}


public extension String {
    func hmac(by algorithm: Algorithm, key: [UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: algorithm.digestLength())
        CCHmac(algorithm.algorithm(), key, key.count, self.bytes, self.bytes.count, &result)
        return result
    }
    
    func hashHex(by algorithm: Algorithm) -> String {
        return algorithm.hash(string: self).hexString
    }
    
    func hash(by algorithm: Algorithm) -> [UInt8] {
        return algorithm.hash(string: self)
    }
}

public enum Algorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func algorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:    result = kCCHmacAlgMD5
        case .SHA1:   result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:    result = CC_MD5_DIGEST_LENGTH
        case .SHA1:   result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    func hash(string: String) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: self.digestLength())
        switch self {
        case .MD5:    CC_MD5(   string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA1:   CC_SHA1(  string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA224: CC_SHA224(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA256: CC_SHA256(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA384: CC_SHA384(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA512: CC_SHA512(string.bytes, CC_LONG(string.bytes.count), &hash)
        }
        return hash
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    var base64String: String {
        return self.data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters)
    }
    var data: Data {
        return Data(self)
    }
}

public extension String {
    var bytes: [UInt8] {
        return [UInt8](self.utf8)
    }
}

public extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

public extension Double {
    func minuteString() -> String {
        let minute = Int(self / 60 )
        let remainSeconds = Int(self.truncatingRemainder(dividingBy: 60))
        var minuteStr = "\(minute)"
        var remainSecondsStr = "\(remainSeconds)"
        if minuteStr.count == 1 {
            minuteStr = "0" + minuteStr
        }
        if remainSecondsStr.count == 1 {
            remainSecondsStr = "0" + remainSecondsStr
        }
        return minuteStr + ":" + remainSecondsStr
    }
}

public extension Int {
    func minuteString() -> String {
        let minute = Int(self / 60 )
        let remainSeconds = Int(self % 60)
        var minuteStr = "\(minute)"
        var remainSecondsStr = "\(remainSeconds)"
        if minuteStr.count == 1 {
            minuteStr = "0" + minuteStr
        }
        if remainSecondsStr.count == 1 {
            remainSecondsStr = "0" + remainSecondsStr
        }
        return minuteStr + ":" + remainSecondsStr
    }
}
