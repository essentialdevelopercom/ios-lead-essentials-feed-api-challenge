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
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		func feedImage() -> FeedImage {
			return .init(id: id,
			             description: description,
			             location: location,
			             url: url)
		}
	}

	func map(data: Data) throws -> [FeedImage] {
		let decodableFeedImages = try JSONDecoder().decode([DecodableFeedImage].self, from: data)
		return decodableFeedImages.map({ $0.feedImage() })
	}
}
