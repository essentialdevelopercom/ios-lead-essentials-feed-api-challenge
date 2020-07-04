//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Alejandro Zamudio Guajardo on 04/07/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {

    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedImage] {
            self.items.map { $0.image }
        }
    }

    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL

        var image: FeedImage {
            FeedImage(id: self.image_id,
                      description: self.image_desc,
                      location: self.image_loc,
                      url: self.image_url)
        }
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }

}
