//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Juan López Bosch on 25/10/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            items.map { $0.feedImage }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var feedImage: FeedImage {
            .init(id: id, description: description, location: location, url: url)
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    private static var goodResponseCode: Int { 200 }
    
    static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard
            response.statusCode == goodResponseCode,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
