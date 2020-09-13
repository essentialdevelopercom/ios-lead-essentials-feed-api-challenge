//
//  FeedIamgeMapper.swift
//  FeedAPIChallenge
//
//  Created by George Liu on 2020/9/13.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation
    
final class FeedImageMapper {
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feedImages)
    }

    struct Root: Decodable {
        private let items: [Image]
        var feedImages: [FeedImage] {
            return items.map { $0.feedImage }
        }

        struct Image: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let url: URL

            var feedImage: FeedImage {
                return FeedImage(
                    id: id,
                    description: description,
                    location: location,
                    url: url
                )
            }

            enum CodingKeys: String, CodingKey {
                case id = "image_id"
                case description = "image_desc"
                case location = "image_loc"
                case url = "image_url"
            }
        }
    }
}
