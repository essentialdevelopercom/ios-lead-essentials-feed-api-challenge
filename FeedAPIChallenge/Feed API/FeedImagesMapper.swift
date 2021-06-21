//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Bryan Hoke on 6/21/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation
final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			items.map(\.image)
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var image: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	static func map(_ data: Data) -> RemoteFeedLoader.Result {
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
