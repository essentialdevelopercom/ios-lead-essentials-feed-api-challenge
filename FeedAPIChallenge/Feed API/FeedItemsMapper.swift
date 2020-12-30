//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Tyler Schwartzman on 12/30/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
	
	private struct Root: Decodable {
		let items: [Image]
	}

	private struct Image: Decodable {
		let imageId: UUID
		let imageDesc: String?
		let imageLoc: String?
		let imageUrl: URL
		
		var item: FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
	}
	
	private static var OK_200: Int { return 200 }
	
	internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return try decoder.decode(Root.self, from: data).items.map { $0.item }
	}
	
}
