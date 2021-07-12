//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by kshitij gupta on 11/07/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private static var OK_200: Int {
		return 200
	}

	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			return items.map({ $0.image })
		}
	}

	private struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = root.feed
		return .success(items)
	}
}
