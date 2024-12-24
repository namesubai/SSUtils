//
//  String+.swift
//  
//
//  Created by yangsq on 2020/11/19.
//

import Foundation
import CommonCrypto
import YYText

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
        var size = str.boundingRect(with: size, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).size
        size = CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
        return size
    }
    
    func oneLineSize(of size: CGSize, font: UIFont) -> CGSize {
        let p = NSMutableParagraphStyle()
        p.maximumLineHeight = font.pointSize
        let str = self as NSString
        var size = str.boundingRect(with: size, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.font : font, .paragraphStyle : p], context: nil).size
        size = CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
        return size
    }
    
}

extension UILabel {
    func autoCalcSize(maxWidth: CGFloat = 0) -> CGSize {
        guard let text = text else { return .zero }
        var maxSize: CGSize = .zero
        if maxWidth > 0{
            maxSize = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        }
//        if numberOfLines == 1 {
//            return text.oneLineSize(of: maxSize, font: font)
//        } else {
//
            return text.size(of: maxSize, font: font)
//        }
       
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
        CCHmac(algorithm.algorithm(), key, key.count, self.ss_bytes, self.ss_bytes.count, &result)
        return result
    }
    
    func hashHex(by algorithm: Algorithm) -> String {
        return algorithm.hash(string: self).hexString
    }
    
    func hash(by algorithm: Algorithm) -> [UInt8] {
        return algorithm.hash(string: self)
    }
    
    /// MD5加密
    func ss_md5() -> String {
        let string = cString(using: String.Encoding.utf8)
        
        let stringLength = CUnsignedInt(lengthOfBytes(using: String.Encoding.utf8))
        
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(string!, stringLength, result)
        
        let hash = NSMutableString()
        
        for iii in 0 ..< digestLength { hash.appendFormat("%02x", result[iii]) }
        
        result.deinitialize(count: digestLength)
        
        return String(format: hash as String)
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
        case .MD5:    CC_MD5(   string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
        case .SHA1:   CC_SHA1(  string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
        case .SHA224: CC_SHA224(string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
        case .SHA256: CC_SHA256(string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
        case .SHA384: CC_SHA384(string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
        case .SHA512: CC_SHA512(string.ss_bytes, CC_LONG(string.ss_bytes.count), &hash)
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
    var ss_bytes: [UInt8] {
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


public extension String {
    var isLength : Bool {
        if self != nil {
            return self.count > 0
        }
        return  false
    }
    
    var lastPathComponent: String {
        (self as NSString).lastPathComponent
    }
    
    var pathExtension: String {
        (self as NSString).pathExtension
    }
    func emojiToImage(size: CGFloat) -> UIImage {
        
        let outputImageSize = CGSize.init(width: size, height: size)
        let baseSize = self.boundingRect(with: CGSize(width: 2048, height: 2048),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: UIFont.systemFont(ofSize: size / 2)], context: nil).size
        let fontSize = outputImageSize.width / max(baseSize.width, baseSize.height) * (outputImageSize.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = self.boundingRect(with: CGSize(width: outputImageSize.width, height: outputImageSize.height),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: font], context: nil).size
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr : [NSAttributedString.Key : Any] = [.font : font,
                                                    .paragraphStyle: style,
                                                    .backgroundColor: UIColor.clear ]
        
        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0)
        self.draw(in: CGRect(x: (size - textSize.width) / 2,
                             y: (size - textSize.height) / 2,
                             width: textSize.width,
                             height: textSize.height),
                  withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
     *去掉首尾空格 后 指定开头空格数
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }
}

public extension NSAttributedString {
    var isLength : Bool {
        return  (self ?? NSAttributedString(string: "")).length > 0
    }
}


private let emailRegex = "[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}"
let urlRegex = "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"
public extension String {
    
    public enum TextTapActoin {
        case url(url: String)
        case email(email: String)
    }
    
    func rangesOfString(pattern: String) -> [NSRange] {
        if let expression = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = expression.matches(in: self, range: NSRange(self.startIndex...,in: self))
            var ranges = [NSRange]()
            for match in matches {
                ranges.append(match.range)
            }
            return ranges
        }
        return []
    }
    
    func urlRangesOfString() -> [NSRange] {
        return rangesOfString(pattern: urlRegex)
    }
    
    func emailRangesOfString() -> [NSRange] {
        return rangesOfString(pattern: emailRegex)
    }
    
    func transformFormatAttrString(color: UIColor,
                                   formatColor: UIColor,
                                   font: UIFont,
                                   formatFont: UIFont? = nil,
                                   contentWidth: CGFloat,
                                   numberLines: Int = 0,
                                   selectBackgroundColor: UIColor? = UIColor.hex(0xf2f2f2), formatOnTrigger: ((TextTapActoin) -> Void)?) -> (string: NSAttributedString, size: CGSize, isHasTail: Bool) {
        let attr = NSMutableAttributedString(string: self)
        attr.yy_color = color
        attr.yy_font = font
        let urlRangs = self.urlRangesOfString()
        for rang in urlRangs {
            attr.yy_setFont(formatFont ?? font, range: rang)
            attr.yy_setColor(formatColor, range: rang)
            
            attr.yy_setTextHighlight(rang, color: formatColor, backgroundColor: selectBackgroundColor) { _, str, range, aa in
                if let trigger = formatOnTrigger {
                    trigger(.url(url: str.attributedSubstring(from: range).string))
                }
            }
        }
        
        let emailRangs = self.emailRangesOfString()
        for range in emailRangs {
            attr.yy_setTextHighlight(range, color: formatColor, backgroundColor: selectBackgroundColor){ _, str, _, _ in
                if let trigger = formatOnTrigger {
                    trigger(.email(email: str.attributedSubstring(from: range).string))
                }
            }
        }
        let textContainer = YYTextContainer(size: CGSize(width: contentWidth, height: CGFloat(MAXFLOAT)))
        textContainer.insets = .zero
        textContainer.maximumNumberOfRows = UInt(numberLines)
        let layout = YYTextLayout(container: textContainer, text: attr)
        return (attr, layout?.textBoundingSize ?? .zero, layout?.range != layout?.visibleRange)
    }
    
   
}


public extension String {
    var isValidEmail: Bool {
        // http://emailregex.com/
        let regex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

public extension String {
    var isNum: Bool {
        Int(self) != nil
    }
   
}
