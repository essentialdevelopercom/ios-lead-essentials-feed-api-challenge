//
//  FeedLoaderMapper.swift
//  FeedAPIChallenge
//
//  Created by sassi walid on 01/03/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedLoaderMapper {

	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case image = "image_url"
		}
	}
	private static var ok_200: Int { return 200 }
	
	static  func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == ok_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = root.feed
		return .success(items)
	}
}

