//
//  FeedItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Developer on 14.08.2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemMapper {
    
    private struct Root: Decodable {
        let root: [Item]
        
        var feed: [FeedImage] {
            root.map { $0.item }
        }
    }
    
    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id,
                             description: image_desc,
                             location: image_loc,
                             url: image_url)
        }
    }
}
