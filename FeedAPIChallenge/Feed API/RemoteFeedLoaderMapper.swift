//
//  RemoteFeedLoaderMapper.swift
//  FeedAPIChallenge
//
//  Created by Riccardo Rossi - Home on 25/02/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class RemoteFeedLoaderMapper {
	
	internal static func map(successInfo: RemoteFeedLoader.DataAndResponse) -> FeedLoader.Result {
		guard successInfo.response.statusCode == RemoteFeedLoaderMapper.OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: successInfo.data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
	
	private static let OK_200 = 200
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feedImages: [FeedImage] {
			return items.map{$0.feedImage}
		}
	}
	
	private struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			return FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: image_url
			)
		}
	}
}
