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
	
	internal init(_ data: [String: Any]) throws {
		guard let idString = data["image_id"] as? String,
			  let id = UUID(uuidString: idString),
			  let urlString = data["image_url"] as? String,
			  let url = URL(string: urlString) else { throw RemoteFeedLoader.Error.invalidData }
		self.id = id
		self.url = url
		self.description = data["image_desc"] as? String
		self.location = data["image_loc"] as? String
	}
}

internal extension RemoteImage {
	var feedImage: FeedImage {
		.init(id: id, description: description, location: location, url: url)
	}
}
