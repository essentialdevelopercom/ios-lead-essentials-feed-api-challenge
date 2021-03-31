//
//  FeedImageDecoding.swift
//  FeedAPIChallenge
//
//  Created by Oleksii Lytvynov-Bohdanov on 26.03.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final internal class FeedImageMapper {
	struct Root: Decodable {
		let items: [Item]
		
		var feedItems: [FeedImage] {
			items.map { $0.item }
		}
	}
	
	struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var item: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	private static var OK_200: Int { 200 }

	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData }
		return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feedItems)
	}
}
