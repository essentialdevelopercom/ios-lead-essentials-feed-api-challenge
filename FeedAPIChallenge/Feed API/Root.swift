//
//  Root.swift
//  FeedAPIChallenge
//
//  Created by Alok Sinha on 2021-04-05.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct Root: Codable {
	let items: [Item]
	
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
	
	static func feedImagesFromData(from data: Data, stausCode: Int)-> FeedLoader.Result {
		guard stausCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.items.map(\.item))
	}
}
