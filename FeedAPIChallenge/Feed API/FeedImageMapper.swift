//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Prateek Roy on 30/08/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let items = try JSONDecoder().decode(Root.self, from: data).items.map{ $0.feedImage }
        return items
    }
    
    static var OK_200: Int {
        return 200
    }
}

private struct Root: Codable {
    let items: [RemoteFeedImage]
}

private struct RemoteFeedImage {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    var feedImage: FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }
}

extension RemoteFeedImage: Codable {
    private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}
