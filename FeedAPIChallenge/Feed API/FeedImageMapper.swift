//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Tan Tan on 5/31/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper {
	struct Root: Decodable {
		var items: [FeedImageResult] = []

		struct FeedImageResult: Decodable {
			public let image_id: UUID
			public let image_desc: String?
			public let image_loc: String?
			public let image_url: URL
		}

		var feedImageItems: [FeedImage] {
			return items.map({ result in
				FeedImage(id: result.image_id, description: result.image_desc, location: result.image_loc, url: result.image_url)
			})
		}
	}

	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		let items = root.feedImageItems
		return .success(items)
	}
}
