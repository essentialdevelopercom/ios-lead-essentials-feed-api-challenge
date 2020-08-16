//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Mario Alberto Barragán Espinosa on 16/08/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImageMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map({ $0.item })
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var item: FeedImage {
            return FeedImage(id: id, description: description, location: location, url: url)
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    private static let OK_200 = 200
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
