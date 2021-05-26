//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Darren Findlay on 26/05/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct RemoteFeedImage: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let imageUrl: URL

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case imageUrl = "image_url"
	}
}
