//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Bogdan Poplauschi on 07/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]
		
		var feedImages: [FeedImage] { items.map { $0.feedImage } }
	}

	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.isValid(),
			  let root: Root = jsonDecode(from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
	
	private static func jsonDecode(from data: Data) -> Root? {
		return try? JSONDecoder().decode(Root.self, from: data)
	}
}

private extension HTTPURLResponse {
	private static var StatusCodeSuccess = 200
	
	func isValid() -> Bool {
		return statusCode == HTTPURLResponse.StatusCodeSuccess
	}
}
