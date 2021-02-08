//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Marko Engelman on 08/02/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}
	
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}
	
	internal static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.isOK else { return .failure(RemoteFeedLoader.Error.invalidData) }
		return Result {
			try JSONDecoder()
				.decode(Root.self, from: data)
				.items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
		}.mapError { _ in RemoteFeedLoader.Error.invalidData }
	}
}

// MARK: - Private
private extension HTTPURLResponse {
	var isOK: Bool { statusCode == 200 }
}
