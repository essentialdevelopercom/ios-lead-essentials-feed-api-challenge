//
//  RemoteFeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Gustavo Londono on 8/5/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct RemoteFeedImageMapper {
    private struct Root: Decodable {
        private var items: [RemoteFeedImage]
        
        var feedImages: [FeedImage] {
            return items.map({ $0.feedImage })
        }
    }
    
    private struct RemoteFeedImage: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var feedImage: FeedImage {
            return FeedImage(id: id, description: description, location: location, url: url)
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    static func mapFeedImage(data: Data, httpResponse: HTTPURLResponse) -> FeedLoader.Result {
        guard httpResponse.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feedImages)
    }
}
