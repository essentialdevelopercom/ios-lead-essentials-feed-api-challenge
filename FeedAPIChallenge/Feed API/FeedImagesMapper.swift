//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Aleksandr Honcharov on 01.06.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

enum FeedImagesMapper {
	private struct Root: Decodable {
		private let items: [Image]

		var feed: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct Image: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	private static let okayResponseCode = 200

	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == okayResponseCode,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feed)
	}
}
