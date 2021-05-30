//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Salar Zarandi on 5/30/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
	private struct Root: Decodable {
		private let items: [Item]

		var feeds: [FeedImage] {
			items.map({ $0.feed })
		}

		private struct Item: Decodable {
			let image_id: UUID
			let image_desc: String?
			let image_loc: String?
			let image_url: URL

			var feed: FeedImage {
				return FeedImage(
					id: image_id,
					description: image_desc,
					location: image_loc,
					url: image_url)
			}
		}
	}

	static func map(from data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feeds)
	}
}
