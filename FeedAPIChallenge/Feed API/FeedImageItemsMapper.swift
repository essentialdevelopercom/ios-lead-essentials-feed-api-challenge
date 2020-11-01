//
//  FeedImageItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Edgar Hirama on 01/11/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageItemsMapper {
    private struct Items: Decodable {
        let items: [ImageItem]

        var feedImageItems: [FeedImage] {
            items.compactMap {
                guard let url = URL(string: $0.imageURL) else { return nil }
                return FeedImage(id: $0.imageId,
                          description: $0.imageDesc,
                          location: $0.imageLoc,
                          url: url)
            }
        }
    }

    private struct ImageItem: Decodable {
        let imageId: UUID
        let imageDesc: String?
        let imageLoc: String?
        let imageURL: String

        enum CodingKeys: String, CodingKey {
            case imageId = "image_id"
            case imageDesc = "image_desc"
            case imageLoc = "image_loc"
            case imageURL = "image_url"
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        guard
            response.statusCode == 200,
            let feedItems = try? JSONDecoder().decode(Items.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)

        }
        return .success(feedItems.feedImageItems)
    }
}
