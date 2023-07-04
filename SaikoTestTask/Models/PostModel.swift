//
//  PostModel.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 3.07.23.
//

import Foundation

struct PostModel: Codable {
    let name: String
    let typeId: Int
    let photo: Data
}
