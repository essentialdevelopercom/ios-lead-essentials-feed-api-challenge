//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Saul Cortez Garcia on 20/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper: Decodable {
	let items: [Item]

	var feedImage: [FeedImage] {
		return items.map {
			FeedImage(id: $0.id,
			          description: $0.description,
			          location: $0.location,
			          url: $0.imageURL)
		}
	}
}

struct Item: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case imageURL = "image_url"
	}
}
