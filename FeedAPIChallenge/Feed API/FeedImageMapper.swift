//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Karthik K Manoj on 23/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Item]

		var feedImages: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		private let imageID: UUID
		private let imageDescription: String?
		private let imageLocation: String?
		private let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageID = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}

		var item: FeedImage {
			FeedImage(id: imageID,
			          description: imageDescription,
			          location: imageLocation,
			          url: imageURL)
		}
	}

	private static var OK_200: Int { 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(FeedImageMapper.Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feedImages)
	}
}
