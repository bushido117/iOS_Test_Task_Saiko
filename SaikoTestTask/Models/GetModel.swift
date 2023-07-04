//
//  GetModel.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 30.06.23.
//

import Foundation

struct GetModel: Codable {
    var content: [Content]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}

struct Content: Codable {
    let id: Int
    let name: String
    let image: String?
}
