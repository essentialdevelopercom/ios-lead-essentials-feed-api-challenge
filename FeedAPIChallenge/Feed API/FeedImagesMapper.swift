//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Jorge Lucena Pino on 30/12/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]
	}

	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}

		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {

		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		return try JSONDecoder().decode(Root.self, from: data).items.map { $0.image }
	}
}
