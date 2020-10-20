//
//  FeedImageRemoteToDomainMapper.swift
//  FeedAPIChallenge
//
//  Created by Carlos Damiao on 20/10/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageRemoteToDomainMapper {
    private struct FeedImageResponse: Decodable {
        struct FeedImageRemote: Decodable{
            let image_id: UUID
            let image_desc: String?
            let image_loc: String?
            let image_url: URL
        }

        let items: [FeedImageRemote]

        func mapIntoFeedImages() -> [FeedImage] {
            items.map {
                FeedImage(id: $0.image_id,
                          description: $0.image_desc,
                          location: $0.image_loc,
                          url: $0.image_url)
            }
        }
    }

    static func mapIntoDomain(from data: Data) -> [FeedImage]? {
        let items = try? JSONDecoder().decode(FeedImageResponse.self, from: data)

        return items?.mapIntoFeedImages()
    }
}
