//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Alix on 4/3/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation


internal class FeedMapper {
	
	private struct Root: Decodable {
		let items: [FeedImageItem]
		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}

	private struct FeedImageItem: Decodable {
		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
		
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
	
	private static let OK_200 = 200
	
	static func map(_ data: Data, response: HTTPURLResponse) ->  FeedLoader.Result{
		if let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == OK_200 {
			return .success(root.images)
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
