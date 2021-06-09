//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by YH Kung on 2021/6/9.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImageMapper {
	private struct Root: Decodable {
		let items: [ImageItem]
	}

	private struct ImageItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	internal static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		let feedImages = root.items.map { $0.image }

		return feedImages
	}
}
