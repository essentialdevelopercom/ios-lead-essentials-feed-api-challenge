//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Fernando Putallaz on 26/03/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
	struct Root: Codable {
		
		var items: [Item]
		
		var images: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	struct Item: Codable {
		var id: UUID
		var description: String?
		var location: String?
		var url: URL
		
		var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
