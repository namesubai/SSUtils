//
//  HRResult.swift
//  
//
//  Created by yangsq on 2020/11/20.
//

import Foundation
import ObjectMapper
import Moya

enum ErrorCode: Int {
    case unKnow = -11001
    case tokenInvalid = 40004
    case parseFailure = -11002
    case unlookCoinNoEnough = 1008
    case anotherLogin = 70007
    case customError = -11003
    case loginExpired = 40008
    case needLogin = 40009
    case signVerifyFailed = 40001

}

enum ResultCode: Int {
    case unKnow = -11001
    case failure = 1
    case success = 0
    case anotherLogin = 70007
    case tokenInvalid = 40004
    case loginExpired = 40008
    case needLogin = 40009
    case signVerifyFailed = 40001

}

enum ServiceError: Swift.Error {
        
    case serverError(response: BaseResult)
    case parseResultError(response: Moya.Response)
    case customError(message: String)
    case unownedError
    var title: String {
        switch self {
          case .serverError(let response): return response.msg ?? ""
          case .parseResultError(_) :
            #if DEBUG
            return  "解析数据错误"
            #else
            return ""
            #endif
        case .customError(let msg) :
            return msg
        case .unownedError:
            return "Unknow Error"
        }
    }

    var errorMsg: String {
        switch self {
          case .serverError(let response): return response.msg ?? ""
          case .parseResultError(_) :
            #if DEBUG
            return "解析失败"
            #else
            return ""
            #endif
        case .customError(let msg) :
            return msg
        case .unownedError:
            return "Unknow Error"
        }
    }
    
    var code: ErrorCode {
        switch self {
          case .serverError(let response):
            return response.errorCode
        case .parseResultError(_) : return ErrorCode.parseFailure
        case .customError(_) : return ErrorCode.customError
        case .unownedError: return ErrorCode.unKnow
        }
    }
}



struct BaseResult: Mappable {
    
    var errorCode: ErrorCode = .unKnow
    var code: ResultCode = .unKnow
    var errorMsg: String?
    var msg: String?
    var requestId: String?
    var responseTime: String?
    var dataIsNil: Bool = false
    var data: String?
    var resultCode: Int? = nil
    init?(map: Map) {
        if map.JSON["data"] == nil {
            self.dataIsNil = true
        }
    }

    mutating func mapping(map: Map) {
        
        resultCode <- map["code"]
        if resultCode == nil {
            code = .unKnow
        }else {
            if let resultCode = ResultCode(rawValue: resultCode!) {
                code = resultCode
            }else {
                code = .unKnow
            }
        }
        var error: Int?
        error <- map["errorCode"]
        if resultCode == nil {
            errorCode = .unKnow
        } else {
            if let code = ErrorCode(rawValue: resultCode!) {
                errorCode = code
            }else {
                errorCode = .unKnow
            }
        }
        
        errorMsg <- map["errorMsg"]
        msg <- map["msg"]
        requestId <- map["request_id"]
        responseTime <- map["response_time"]
        var dataString = ""
        dataString <- map["data"]
        data = decodeData(data: dataString)
    }
}


let AESKEY = "fLZk3cmTyGBz9ZYD"
let AESIV = "ZGt3RgHrgHaZ6xKr"
//import CryptoSwift
extension BaseResult {
    func decodeData(data: String) -> String {
//        do {
//            let aes = try AES(key: AESKEY, iv: AESIV)
////            let decrypted = try data.decryptBase64ToString(cipher: aes)
////            return decrypted
//            return ""
//        } catch {
            return ""
//        }
        
    }
}
