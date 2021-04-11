//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Livia Vasconcelos on 11/04/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let images: [Image]
		
		var feed: [FeedImage] {
			return images.map { $0.images }
		}
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		var images: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	internal static func map(_ data: Data,
							 from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feed)
	}
}
