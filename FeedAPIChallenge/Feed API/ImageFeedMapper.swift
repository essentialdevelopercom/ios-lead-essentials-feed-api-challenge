//
//  ImageFeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Romain Brunie on 22/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class ImageFeedMapper {
	private struct Root: Decodable {
		let items: [Image]
		
		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}
	
	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var image: FeedImage {
			FeedImage(id: image_id,
					  description: image_desc,
					  location: image_loc,
					  url: image_url)
		}
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let json = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(json.images)
	}
}
