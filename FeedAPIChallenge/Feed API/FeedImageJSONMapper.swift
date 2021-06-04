//
//  FeedImageJSONMapper.swift
//  FeedAPIChallenge
//
//  Created by Константин Богданов on 04.06.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageJSONMapper: FeedImageMapper {
	private struct DecodableFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		func feedImage() -> FeedImage {
			return .init(id: image_id,
			             description: image_desc,
			             location: image_loc,
			             url: image_url)
		}
	}

	private struct Response: Decodable {
		let items: [DecodableFeedImage]
	}

	func map(data: Data) throws -> [FeedImage] {
		let decodableFeedImages = try JSONDecoder().decode(Response.self, from: data)
		return decodableFeedImages.items.map({ $0.feedImage() })
	}
}
