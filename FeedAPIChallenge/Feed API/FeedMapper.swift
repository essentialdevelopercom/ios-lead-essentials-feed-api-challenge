//
//  FeedImageList.swift
//  FeedAPIChallenge
//
//  Created by Ajoy Kumar on 14/06/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedMapper {
	private struct ImageList: Decodable {
		let items: [Images]
	}

	private struct Images: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(_ data: Data, with response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200,
		      let list = try? JSONDecoder().decode(ImageList.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return list.items.map { $0.image }
	}
}
