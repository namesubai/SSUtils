//
//  HRResult.swift
//  
//
//  Created by yangsq on 2020/11/20.
//

import Foundation
import ObjectMapper
import Moya
//
//public enum ErrorCode: Int {
//    case unKnow = -11001
//    case tokenInvalid = 40004
//    case parseFailure = -11002
//    case unlookCoinNoEnough = 1008
//    case anotherLogin = 70007
//    case customError = -11003
//    case loginExpired = 40008
//    case needLogin = 40009
//    case signVerifyFailed = 40001
//
//}


public enum ServiceErrorCode: Int {
    case unKnow = -11001
    case parseFailure = -11002
    case customError = -11003

}

public enum ServiceError: Swift.Error{
        
    case serverError(response: RootResult)
    case parseResultError
    case customError(message: String)
    case unownedError
    public var title: String {
        switch self {
          case .serverError(let response): return response.msg ?? ""
          case .parseResultError:
            #if DEBUG
            return  "解析数据错误"
            #else
            return localized(name: "network_error_common_msg")
            #endif
        case .customError(let msg) :
            return msg
        case .unownedError:
            return "Unknow Error"
        }
    }

    public var errorMsg: String {
        switch self {
          case .serverError(let response): return response.msg ?? ""
          case .parseResultError :
            #if DEBUG
            return "解析数据错误"
            #else
            return localized(name: "network_error_common_msg")
            #endif
        case .customError(let msg) :
            return msg
        case .unownedError:
            return "Unknow Error"
        }
    }
    
    public var code: Int {
        switch self {
          case .serverError(let response):
            return response.code
        case .parseResultError : return ServiceErrorCode.parseFailure.rawValue
        case .customError(_) : return ServiceErrorCode.customError.rawValue
        case .unownedError: return ServiceErrorCode.unKnow.rawValue
        }
    }
}

public protocol RootResult: Mappable {
    var msg: String? { get }
    var code: Int { get }
    var isSuccess: Bool { get }
    /// 需要转换的jsonstring
    var needMapJsonString: String? { get }
    /// 是否对result进行加密？
    var isEncrypt: Bool { get }
}

extension RootResult {
    public var isEncrypt: Bool { false }
}




//public struct BaseResult: Mappable {
//    public var isSuccess: Bool = true
////
////    public var code: Int {
////       return 0
////    }
////
//    
//    public var errorCode: ErrorCode = .unKnow
//    public var code: ResultCode = .unKnow
//    public var errorMsg: String?
//    public var msg: String?
//    public var requestId: String?
//    public var responseTime: String?
//    public var dataIsNil: Bool = false
//    public var data: String?
//    public var resultCode: Int? = nil
//    public init?(map: Map) {
//        if map.JSON["data"] == nil {
//            self.dataIsNil = true
//        }
//    }
//
//    mutating public func mapping(map: Map) {
//        
//        resultCode <- map["code"]
////        if resultCode == nil {
////            code = .unKnow
////        }else {
////            if let resultCode = ResultCode(rawValue: resultCode!) {
////                code = resultCode
////            }else {
////                code = .unKnow
////            }
////        }
//        var error: Int?
//        error <- map["errorCode"]
////        if resultCode == nil {
////            errorCode = .unKnow
////        } else {
////            if let code = ErrorCode(rawValue: resultCode!) {
////                errorCode = code
////            }else {
////                errorCode = .unKnow
////            }
////        }
//        
//        errorMsg <- map["errorMsg"]
//        msg <- map["msg"]
//        requestId <- map["request_id"]
//        responseTime <- map["response_time"]
//        var dataString = ""
//        dataString <- map["data"]
//        data = decodeData(data: dataString)
//    }
//}



