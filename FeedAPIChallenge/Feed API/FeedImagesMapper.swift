//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by chihyin wang on 2020/8/5.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImagesMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feedImages: [FeedImage] {
            return items.map { FeedImage(id: $0.image_id,
                                         description: $0.image_desc,
                                         location: $0.image_loc,
                                         url: $0.image_url) }
        }
    }
    
    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }
    
    private static var validStatusCode = 200

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == validStatusCode, let json = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(json.feedImages)
    }
}

