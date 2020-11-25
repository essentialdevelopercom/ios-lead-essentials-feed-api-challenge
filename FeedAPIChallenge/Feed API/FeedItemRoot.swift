//
//  FeedItemRoot.swift
//  FeedAPIChallenge
//
//  Created by Marcelo  Carvalho on 24/11/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation


internal struct FeedItemRoot: Codable {
    
    let items: [FeedImageModel]
}

internal struct FeedImageModel: Codable {
    
    let imageId: UUID
    var desc: String?
    var location: String?
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case desc = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}
