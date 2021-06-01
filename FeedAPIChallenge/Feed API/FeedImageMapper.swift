//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Karthik K Manoj on 23/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private struct Root: Decodable {
		private let items: [Item]

		var feedImages: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var item: FeedImage {
			FeedImage(id: image_id,
			          description: image_desc,
			          location: image_loc,
			          url: image_url)
		}
	}

	private static var OK_200: Int { 200 }

	static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feedImages)
	}
}
