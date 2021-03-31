//
//  FeedImageDecoding.swift
//  FeedAPIChallenge
//
//  Created by Oleksii Lytvynov-Bohdanov on 26.03.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImages: Decodable {
	let items: [FeedImage]
}

struct CodableFeedImage: Decodable {
	private enum codingKeys: CodingKey {
		case image_id
		case image_desc
		case image_loc
		case image_url
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: codingKeys.self)
		
		id = try container.decode(UUID.self, forKey: .image_id)
		description = try container.decodeIfPresent(String.self, forKey: .image_desc)
		location = try container.decodeIfPresent(String.self, forKey: .image_loc)
		url = try container.decode(URL.self, forKey: .image_url)
	}
}
