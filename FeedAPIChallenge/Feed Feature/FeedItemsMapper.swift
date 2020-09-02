//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Eric Sans on 02/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [FeedImage]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
