//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Salah Amassi on 10/02/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	
	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	private struct Root: Decodable {
		let items: [Item]
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map(\.item)
	}
}
