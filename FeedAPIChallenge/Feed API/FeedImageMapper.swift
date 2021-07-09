//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Gowtham Namuri on 09/07/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [FeedItem]

		var feedImages: [FeedImage] {
			items.map({ FeedImage(id: $0.uuid, description: $0.description, location: $0.location, url: $0.imageURL) })
		}
	}

	private struct FeedItem: Decodable {
		let uuid: UUID
		let description: String?
		let location: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case uuid = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}

	internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let feedItemsRoot = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(feedItemsRoot.feedImages)
	}
}
