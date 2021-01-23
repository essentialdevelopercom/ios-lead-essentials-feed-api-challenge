//
//  ItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Alberto Garcia Paul on 22/01/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public struct ItemsMapper {
	private struct Root: Decodable {
		let items: [Image]
		
		var images: [FeedImage] {
			return items.map { $0.image }
		}
	}
	
	private struct Image: Decodable {
		let imageId: UUID
		let imageDesc: String?
		let imageLoc: String?
		let imageUrl: URL
		
		var image: FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
	}
	
	public static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		guard response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
