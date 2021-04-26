//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Shashank Mishra on 25/04/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private static var OK_200 = 200

	private struct Root: Decodable {
		let items: [Item]
		var feedImages: [FeedImage] {
			return items.map({ $0.feed })
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		var feed: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
}
