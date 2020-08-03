//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Thiago Ramos on 02/08/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
    static func map(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200,
              let root: Root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        let feedImages = root.items.map { dto in
            FeedImage(id: dto.id, description: dto.description, location: dto.location, url: dto.url)
        }

        return .success(feedImages)
    }
    
    private struct Root: Decodable {
        var items: [FeedImageDto]
    }

    private struct FeedImageDto: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var url: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
}
