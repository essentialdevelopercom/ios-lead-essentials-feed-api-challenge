//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Rafael Bonini on 8/6/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
    private struct FeedImageArray: Decodable {
        private let items: [Item]
        
        var feedImages: [FeedImage] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        private let image_id: UUID
        private let image_desc: String?
        private let image_loc: String?
        private let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id,
                             description: image_desc,
                             location: image_loc,
                             url: image_url
            )
        }
    }

    private static let http_200 = 200
    static func mapSuccessResult(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == http_200,
            let decodedData = try? JSONDecoder().decode(FeedImageArray.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(decodedData.feedImages)
    }
}
