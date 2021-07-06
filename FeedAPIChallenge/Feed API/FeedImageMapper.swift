//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by YH Kung on 2021/6/9.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
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

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		let feedImages = root.items.map { $0.image }
		return .success(feedImages)
	}
}
