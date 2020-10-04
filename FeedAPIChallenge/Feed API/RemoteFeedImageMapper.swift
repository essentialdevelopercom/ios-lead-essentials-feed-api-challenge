//
//  RemoteFeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Andres Rivas on 04-10-20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class RemoteFeedImageMapper {
    
    static var validHTTPResponseCode: Int = 200
    
    private struct RemoteFeedImageRoot: Decodable {
        
        var items: [RemoteFeedImage]
        
        var feedItems: [FeedImage] {
            items.map { $0.feedImage }
        }
    }

    private struct RemoteFeedImage: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var url: URL
        
        var feedImage: FeedImage {
            return FeedImage(id: id,
                             description: description,
                             location: location,
                             url: url)
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    static func map(_ data: Data,
                    from response: HTTPURLResponse) -> FeedLoader.Result {
        
        guard response.statusCode == validHTTPResponseCode,
              let items = try? JSONDecoder().decode(RemoteFeedImageRoot.self, from: data).feedItems else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(items)
    }
}
