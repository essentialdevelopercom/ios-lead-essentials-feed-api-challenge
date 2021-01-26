//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Chad Chang on 2021/1/24.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private static var OK_200: Int { return 200 }

	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(data: Data, response: HTTPURLResponse) throws ->  [FeedImage] {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(FeedImagesMapper.Root.self, from: data) else  {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items.map { $0.image }
	}
}
