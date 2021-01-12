//
//  RemoteImage.swift
//  FeedAPIChallenge
//
//  Created by Ivan Ornes on 10/1/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteImageResponse: Decodable {
	private let items: [RemoteImage]
}

internal extension RemoteImageResponse {
	var feedItems: [FeedImage] { items.map { $0.feedImage } }
}

internal struct RemoteImage: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL
	
	private enum CodingKeys : String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}

internal extension RemoteImage {
	var feedImage: FeedImage {
		.init(id: id, description: description, location: location, url: url)
	}
}
