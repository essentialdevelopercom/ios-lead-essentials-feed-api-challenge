//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Angel Aguilar on 7/14/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]
		var feed: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: image_url
			)
		}
	}

	private static var OK_200: Int { 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
