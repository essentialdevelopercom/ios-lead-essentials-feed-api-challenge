//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Abdoulaye Diallo on 4/16/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
	struct Root: Codable {
		let items: [FeedImageItem]
		public var feedImages: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}
	
	struct FeedImageItem: Codable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		public var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	private static var OK_200 = 200
	
	internal static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feedImages)
	}
}
