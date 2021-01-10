//
//  RemoteImage.swift
//  FeedAPIChallenge
//
//  Created by Ivan Ornes on 10/1/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteImage: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL
	
	internal init?(_ data: [String: Any]) {
		guard let idString = data["image_id"] as? String,
			  let id = UUID(uuidString: idString),
			  let urlString = data["image_url"] as? String,
			  let url = URL(string: urlString) else { return nil }
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
