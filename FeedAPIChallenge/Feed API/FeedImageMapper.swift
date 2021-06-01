//
//  RemoteFeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Vladimir Jeremic on 4/13/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct RootItem: Decodable {
		let items: [FeedImageItem]

		var feedImages: [FeedImage] {
			return items.map({ $0.feedImage })
		}
	}

	private struct FeedImageItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	private static let OK_200_HTTP_SATUS_CODE = 200

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard FeedImageMapper.OK_200_HTTP_SATUS_CODE == response.statusCode,
		      let rootItem = try? JSONDecoder().decode(RootItem.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(rootItem.feedImages)
	}
}
