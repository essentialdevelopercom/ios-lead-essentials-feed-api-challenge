//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/01/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImagesMapper {
	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		let items = root.items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }

		return .success(items)
	}
}


private struct Root: Decodable {
	var items: [APIFeedImage]
}

private struct APIFeedImage: Decodable {
	var image_id: UUID
	var image_desc: String?
	var image_loc: String?
	var image_url: URL
}
