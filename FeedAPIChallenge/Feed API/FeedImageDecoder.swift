//
//  FeedImageDecoder.swift
//  FeedAPIChallenge
//
//  Created by Oliver Jordy Pérez Escamilla on 13/12/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageDecoder {
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feedImages: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let imageURL: URL
		
		var feedImage: FeedImage {
			FeedImage(id: id,
								description: description,
								location: location,
								url: imageURL)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}
	
	static func decode(data: Data) -> [FeedImage]? {
		(
			try? JSONDecoder().decode(Root.self, from: data)
		)?
		.feedImages
	}
}
