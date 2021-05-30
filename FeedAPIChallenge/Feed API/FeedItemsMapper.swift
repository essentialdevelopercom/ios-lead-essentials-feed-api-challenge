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
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
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
