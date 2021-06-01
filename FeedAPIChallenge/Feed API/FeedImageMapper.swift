//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Andreas Link on 10.04.21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

enum FeedImageMapper {
	private enum Constants {
		static let OK_200: UInt = 200
	}

	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		let id: UUID
		let description: String?
		let location: String?
		let url: URL
	}

	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == Constants.OK_200 else { return .failure(RemoteFeedLoader.Error.invalidData) }

		do {
			let root: Root = try JSONDecoder().decode(Root.self, from: data)
			let images: [FeedImage] = root.items.map { item in
				return FeedImage(
					id: item.id,
					description: item.description,
					location: item.location,
					url: item.url
				)
			}

			return .success(images)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
