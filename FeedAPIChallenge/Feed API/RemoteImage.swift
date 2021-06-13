//
//  RemoteImage.swift
//  FeedAPIChallenge
//
//  Created by Daniel Gallego Peralta on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteImage: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}
