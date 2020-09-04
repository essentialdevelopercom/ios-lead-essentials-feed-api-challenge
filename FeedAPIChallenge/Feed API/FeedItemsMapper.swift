//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Christophe Bugnon on 04/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map {
                FeedImage(id: $0.id,
                          description: $0.description,
                          location: $0.location,
                          url: $0.imageURL
                )
            }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case imageURL = "image_url"
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
