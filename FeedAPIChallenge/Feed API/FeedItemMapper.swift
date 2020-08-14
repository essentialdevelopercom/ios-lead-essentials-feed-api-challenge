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
        let items: [Item]
        
        var feed: [FeedImage] {
            items.map { $0.item }
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
    
    private static var OK_200 = 200
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
