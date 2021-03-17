//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Tim Mikelj on 17/03/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
	
	private struct Root: Decodable {
		
		private struct FeedItem: Decodable {
			let id: UUID
			let description: String?
			let location: String?
			let url: URL
			
			private enum CodingKeys: String, CodingKey {
				case id = "image_id"
				case description = "image_desc"
				case location = "image_loc"
				case url = "image_url"
			}
		}
		
		private let items: [FeedItem]
		
		var images: [FeedImage] {
			items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
		}
	}
	
	private static func rootObject(from data: Data) -> Root? {
		try? JSONDecoder().decode(Root.self, from: data)
	}
	
	static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200, let root = rootObject(from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return root.images
	}
}
