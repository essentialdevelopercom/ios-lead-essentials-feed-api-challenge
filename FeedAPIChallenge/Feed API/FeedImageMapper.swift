//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Vishal on 21/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
    struct Root: Decodable {
        let items: [Item]
    }
    struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL

        private enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }

    private static let OK_200 = 200

    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        let items = root.items.map { (item) -> FeedImage in
            return FeedImage(
                id: item.id,
                description: item.description,
                location: item.location,
                url: item.url
            )
        }

        return .success(items)
    }
}
