//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Ahmed Atef Ali Ahmed on 02.07.21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private static let OK_STATUS_CODE = 200

	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_STATUS_CODE,
		      let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}

private struct Root: Decodable {
	struct APIFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	let items: [APIFeedImage]

	var images: [FeedImage] {
		items.map(FeedImage.init)
	}
}

private extension FeedImage {
	init(_ apiFeedImage: Root.APIFeedImage) {
		self.init(id: apiFeedImage.image_id,
		          description: apiFeedImage.image_desc,
		          location: apiFeedImage.image_loc,
		          url: apiFeedImage.image_url)
	}
}
