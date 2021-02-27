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
	}
	
	struct Image: Decodable {
		public let image_id: UUID
		public let image_desc: String?
		public let image_loc: String?
		public let image_url: URL
	}
	
	private static var OK_200: Int { return 200 }
	
	public static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
			  let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success([])
	}
}
