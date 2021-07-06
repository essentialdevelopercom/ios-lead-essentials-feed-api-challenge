//
//  ImageFeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Madhur Jain on 03/06/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class ImageFeedMapper {
	private struct Root: Decodable {
		let items: [Item]
		var imageFeed: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		public let image_id: UUID
		public let image_desc: String?
		public let image_loc: String?
		public let image_url: URL

		var item: FeedImage {
			return FeedImage(id: image_id,
			                 description: image_desc,
			                 location: image_loc,
			                 url: image_url)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.imageFeed)
	}
}
