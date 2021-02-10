//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Ali Adam on 09/02/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	private enum HttpStatus: Int {
		case ok = 200
	}
	private struct Items: Decodable {
		let items: [Item]
	}
	
	private struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == HttpStatus.ok.rawValue  else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Items.self, from: data)
		return root.items.map(mapToFeedImage)
	}
	
	private static func mapToFeedImage(_ item: Item) -> FeedImage {
		FeedImage(id: item.image_id, description: item.image_desc, location: item.image_loc, url: item.image_url)
	}
	
}
