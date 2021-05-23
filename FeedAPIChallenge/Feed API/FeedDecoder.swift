//
//  FeedDecoder.swift
//  FeedAPIChallenge
//
//  Created by Karthik K Manoj on 23/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageRoot: Decodable {
	let items: [FeedImageItem]
}

struct FeedImageItem: Decodable {
	let imageID: String
	let imageDescription: String?
	let imageLocation: String?
	let imageURL: String

	enum CodingKeys: String, CodingKey {
		case imageID = "image_id"
		case imageDescription = "image_desc"
		case imageLocation = "image_loc"
		case imageURL = "image_url"
	}
}
