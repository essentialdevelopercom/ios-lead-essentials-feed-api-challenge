//
//  FeedImageEntity.swift
//  FeedAPIChallenge
//
//  Created by Andreas Link on 10.04.21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageEntity: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let imageUrl: URL
}

extension FeedImageEntity {
	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case imageUrl = "image_url"
	}
}
