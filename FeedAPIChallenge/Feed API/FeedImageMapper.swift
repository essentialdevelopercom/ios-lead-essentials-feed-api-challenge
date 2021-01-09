//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Francisco Conelli on 09/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	
	private struct FeedImagesResponse: Decodable {
		let items: [Image]
	}

	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		let root = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
		return root.items.map { $0.image }
	}
}
