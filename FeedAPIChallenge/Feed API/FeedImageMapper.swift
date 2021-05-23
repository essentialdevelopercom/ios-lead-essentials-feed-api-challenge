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
		let items: [Item]

		var feedImages: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let image: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case image = "image_url"
		}

		var item: FeedImage {
			FeedImage(id: id,
			          description: description,
			          location: location,
			          url: image)
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
