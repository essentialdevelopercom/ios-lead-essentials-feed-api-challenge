//
//  FeedItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Robert Dates on 11/1/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedItemMapper {
    
    struct Root: Codable {
        let items: [Item]
    }

    struct Item: Codable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    static func mapJSONToFeedImage(from data: Data) -> [FeedImage]? {
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else { return nil }
        return root.items.map { $0.item }
    }
}
