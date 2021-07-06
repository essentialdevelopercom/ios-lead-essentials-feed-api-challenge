//
//  FeedImageJSONMapper.swift
//  FeedAPIChallenge
//
//  Created by Константин Богданов on 04.06.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageJSONMapper {
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

	static func map(data: Data, from httpResponse: HTTPURLResponse) -> FeedLoader.Result {
		if httpResponse.statusCode == 200,
		   let response = try? JSONDecoder().decode(Response.self,
		                                            from: data) {
			return .success(response.items.map({ $0.feedImage() }))
		}
		return .failure(RemoteFeedLoader.Error.invalidData)
	}
}
