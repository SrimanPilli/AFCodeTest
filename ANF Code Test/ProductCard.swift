//
//  ProductCard.swift
//  ANF Code Test
//
//  Created by SaiSriman on 10/27/25.
//

import Foundation

struct ContentButton: Decodable {
    let title: String
    let target: String
}

struct ProductCard: Decodable {
    let title: String
    let promoMessage: String?
    let backgroundImage: String?
    let topDescription: String?
    let bottomDescription: String?
    let content: [ContentButton]?
    var imageData: Data?
}
