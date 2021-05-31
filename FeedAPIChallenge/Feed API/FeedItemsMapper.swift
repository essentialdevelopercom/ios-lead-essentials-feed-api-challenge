//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Vlastimir Radojevic on 31.5.21..
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
	private struct Root: Decodable {
		private let items: [FeedItem]

		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}

	private struct FeedItem: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var item: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      let data = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(data.feed)
	}
}
