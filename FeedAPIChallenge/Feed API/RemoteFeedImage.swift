//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Luis Zapata on 17-06-21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteFeedImageResponse: Codable {
	let items: [RemoteFeedImage]?
}

internal struct RemoteFeedImage: Codable {
	let imageID: String
	let imageDesc, imageLOC: String?
	let imageURL: String

	enum CodingKeys: String, CodingKey {
		case imageID = "image_id"
		case imageDesc = "image_desc"
		case imageLOC = "image_loc"
		case imageURL = "image_url"
	}
}
