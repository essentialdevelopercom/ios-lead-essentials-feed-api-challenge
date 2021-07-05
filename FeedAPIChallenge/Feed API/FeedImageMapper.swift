//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Josue Quiñones on 05/07/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Item]

		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}

	private struct Item: Decodable {
		public let imageId: UUID
		public let imageDesc: String?
		public let imageLoc: String?
		public let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDesc = "image_desc"
			case imageLoc = "image_loc"
			case imageURL = "image_url"
		}

		var image: FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageURL)
		}
	}

	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.images)
	}
}
