//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by John Roque Jorillo on 2/11/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemMapper {
	
	private struct Root: Decodable {
		internal let items: [Item]
		
		internal var feed: [FeedImage] {
			items.map(\.item)
		}
	}

	private struct Item: Decodable {
		internal let id: UUID
		internal let description: String?
		internal let location: String?
		internal let url: URL
		
		var item: FeedImage {
			FeedImage(id: id,
							description: description,
							location: location,
							url: url)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	private static var OK_200: Int { 200 }
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
			  let items = try? JSONDecoder().decode(Root.self, from: data).feed else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(items)
	}
	
}
