//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Ahmed Atef Ali Ahmed on 02.07.21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public protocol FeedImageMapper {
	func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result
}

public final class RemoteFeedImageMapper: FeedImageMapper {
	public static let `default` = RemoteFeedImageMapper()

	private static let OK_STATUS_CODE = 200

	public func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == Self.OK_STATUS_CODE,
		      let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}

struct Root: Decodable {
	struct APIFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	var items: [APIFeedImage]?

	var images: [FeedImage] {
		guard let items = items else { return [] }
		return items.map(FeedImage.init)
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
