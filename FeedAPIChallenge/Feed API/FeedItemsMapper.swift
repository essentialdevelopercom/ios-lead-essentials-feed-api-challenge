//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Chris on 2021-05-02.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var item: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		let root = try JSONDecoder().decode(Root.self, from: data)

		return root.items.map({ $0.item })
	}
}
