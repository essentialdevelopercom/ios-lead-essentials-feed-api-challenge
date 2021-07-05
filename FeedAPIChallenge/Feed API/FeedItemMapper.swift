//
//  Root.swift
//  FeedAPIChallenge
//
//  Created by Gordon Feng on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public final class FeedItemMapper {
	private struct Root: Codable {
		let items: [Item]
		var feedImages: [FeedImage] {
			return items.map({ $0.feedImage })
		}
	}

	private struct Item: Codable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		var feedImage: FeedImage {
			return FeedImage(id: self.image_id,
			                 description: self.image_desc,
			                 location: self.image_loc,
			                 url: self.image_url)
		}
	}

	private static let ok_code = 200
	public static func mapping(_ data: Data, from response: HTTPURLResponse) -> Result<[FeedImage], Error> {
		guard response.statusCode == ok_code else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		do {
			let root = try JSONDecoder().decode(Root.self, from: data)
			return .success(root.feedImages)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
