//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by kshitij gupta on 11/07/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
	private static var OK_200: Int {
		return 200
	}

	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			return items.map({ $0.item })
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = root.feed
		return .success(items)
	}
}
