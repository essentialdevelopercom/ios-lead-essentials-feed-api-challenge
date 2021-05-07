//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Arup Sarkar on 5/4/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let id: UUID //Required
		let description: String? //Optional String
		let location: String? //optional
		let image: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.items.map { $0.item })
	}
}
