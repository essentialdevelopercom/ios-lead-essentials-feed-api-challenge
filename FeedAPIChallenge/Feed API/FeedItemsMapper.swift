//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Mauricio Figueroa olivares on 19-07-20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {

    private static var CODE_200: Int { return 200 }

    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedImage] {
            return items.map { $0.image }
        }
    }

    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL

        var image: FeedImage {
            FeedImage(
                id: self.image_id,
                description: self.image_desc,
                location: self.image_loc,
                url: self.image_url
            )
        }
    }

    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        if response.statusCode == CODE_200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.feed)
        }

        return .failure(RemoteFeedLoader.Error.invalidData)
    }
}

