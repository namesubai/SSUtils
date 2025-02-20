//
//  PageData.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/16.
//

import Foundation
import ObjectMapper

public struct PagingData: Mappable {

    var total: Int?
    var pageSize: Int?
    var pageNo: Int?

    public init?(map: Map) {}

    mutating public func mapping(map: Map) {
        total <- map["total"]
        pageSize <- map["page_size"]
        pageNo <- map["page_no"]
    }
}
