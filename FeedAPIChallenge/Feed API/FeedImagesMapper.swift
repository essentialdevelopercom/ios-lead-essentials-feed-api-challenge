//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Arup Sarkar on 5/4/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Item]
		var feed: [FeedImage] {
			return items.map({ $0.item })
		}
	}

	private struct Item: Decodable {
		let id: UUID //Required
		let description: String? //Optional String
		let location: String? //optional
		let url: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private static var OK_200: Int { return 200 }

	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
