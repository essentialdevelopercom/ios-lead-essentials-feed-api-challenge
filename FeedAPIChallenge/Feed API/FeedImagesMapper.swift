//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Vladimir Mironiuk on 05.06.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private struct Root: Decodable {
		private let items: [Image]

		var feedImages: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct Image: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var feedImage: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static private let HTTPResponseStatusCode200 = 200

	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == HTTPResponseStatusCode200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feedImages)
	}
}
