//
//  ItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Erich Flock on 09.10.20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class ItemsMapper {
    
    private struct Root: Decodable {
        
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL

        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    func mapJsonResponse(jsonResponse: Data) -> [FeedImage]? {
        
        do {
            let root = try JSONDecoder().decode(ItemsMapper.Root.self, from: jsonResponse)
            return root.feed
        } catch {
            return nil
        }
        
    }
}
