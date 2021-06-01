//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Dmitry Tsurkan on 24.05.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [FeedImageItem]
	}

	private struct FeedImageItem: Decodable {
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

		var feedImage: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		if response.statusCode == 200,
		   let root = try? JSONDecoder().decode(Root.self, from: data) {
			return root.items.map { $0.feedImage }
		} else {
			throw RemoteFeedLoader.Error.invalidData
		}
	}
}
