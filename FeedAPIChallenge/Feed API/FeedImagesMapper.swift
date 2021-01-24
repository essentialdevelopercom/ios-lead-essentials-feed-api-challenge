//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Chatharoo on 24/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Feed: Decodable {
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
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
		
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Feed.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.images)
	}
}
