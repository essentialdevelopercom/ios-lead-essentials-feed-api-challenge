//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Eric Garlock on 2/4/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}
	private struct RemoteFeedImage: Decodable {
		public let id: UUID
		public let description: String?
		public let location: String?
		public let url: URL
		
		public init(id: UUID, description: String?, location: String?, url: URL) {
			self.id = id
			self.description = description
			self.location = location
			self.url = url
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		var model: FeedImage {
			return FeedImage(
				id: id,
				description: description,
				location: location,
				url: url
			)
		}
	}
	
	static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		let items = root.items.map { $0.model }
		return .success(items)
	}
}
