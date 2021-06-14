//
//  RemoteFeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Errol on 14/06/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class RemoteFeedMapper {
	static func map(data: Data, with response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(RemoteFeedRoot.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feedImages)
	}

	private struct RemoteFeedRoot: Decodable {
		private let items: [RemoteFeedImage]

		var feedImages: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct RemoteFeedImage: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var feedImage: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
