//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by sherif kamal on 25/06/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]
		var feedImages: [FeedImage] {
			items.map({ $0.item })
		}
	}

	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private static var ok_200: Int { return 200 }

	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == ok_200,
		      let items = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(items.feedImages)
	}
}
