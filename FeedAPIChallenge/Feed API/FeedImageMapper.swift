//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Jean Mouton on 26/11/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { Self.map(feedItem: $0) }
    }
    
    private static func map(feedItem: RemoteFeedImage) -> FeedImage {
        return FeedImage(
            id: feedItem.id,
            description: feedItem.description,
            location: feedItem.location,
            url: feedItem.url)
    }
}
