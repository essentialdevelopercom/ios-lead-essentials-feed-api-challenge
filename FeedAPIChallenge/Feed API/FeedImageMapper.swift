//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Onyekachi Ezeoke on 16/04/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Item]
		var feedImages: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
}
