//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Jackson Chui on 2/26/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImagesMapper {
	
	private struct Root: Decodable {
		public let items: [Image]
		
		public var feedImages: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}
	
	private struct Image: Decodable {
		public let image_id: UUID
		public let image_desc: String?
		public let image_loc: String?
		public let image_url: URL
		
		public var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	private static var OK_200: Int { return 200 }
	
	internal static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
}
