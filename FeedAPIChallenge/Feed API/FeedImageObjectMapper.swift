//
//  FeedImageObjectMapper.swift
//  FeedAPIChallenge
//
//  Created by Khoi Nguyen on 16/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageObjectMapper {
    static func map(_ data: Data) throws -> [FeedImage] {
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.items.map { $0.feedImage }
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}

private struct Root: Decodable {
    let items: [RemoteFeedImage]
}

private struct RemoteFeedImage: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL

    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
    
    var feedImage: FeedImage {
        return FeedImage(
            id: id,
            description: description,
            location: location,
            url: url)
    }
}
