//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Cristian Spiridon on 20/10/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImageMapper {
    
    private struct Root:Decodable {
        
        private struct HTTPItemResponse:Decodable {
            let image_id: UUID
            let image_desc: String?
            let image_loc: String?
            let image_url: URL
        }
        
        private let items:[HTTPItemResponse]
    
        var feedItems:[FeedImage] {
            return items.map {
                FeedImage(
                    id: $0.image_id,
                    description: $0.image_desc,
                    location: $0.image_loc,
                    url: $0.image_url)
            }
        }
    }

    internal static func map(data:Data, response:HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
            }
        return .success(root.feedItems)
    }
}
