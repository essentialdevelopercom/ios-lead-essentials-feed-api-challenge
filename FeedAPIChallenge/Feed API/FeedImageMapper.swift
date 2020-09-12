//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Aaron Huánuco on 12/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
    private typealias Error = RemoteFeedLoader.Error
    private static var OK_STATUS: Int { 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        if response.statusCode == OK_STATUS,
            let feedRoot = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(feedRoot.items.map(\.toFeedImage))
        } else {
            return .failure(Error.invalidData)
        }
    }

    private struct Root: Decodable {
        let items: [FeedImageResponse]
    }

    private struct FeedImageResponse: Decodable {
        private let image_id: UUID
        private let image_desc: String?
        private let image_loc: String?
        private let image_url: URL

        var toFeedImage: FeedImage {
            FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
}
