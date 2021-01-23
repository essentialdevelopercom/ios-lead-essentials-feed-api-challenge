//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Martyn Pękala on 23/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
	
	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == RemoteFeedLoader.OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.items.map { FeedImage(
			id: $0.image_id,
			description: $0.image_desc,
			location: $0.image_loc,
			url: $0.image_url
		) })
	}
	
	struct Root: Decodable {
		
		let items: [FeedImageModel]
		
	}

	struct FeedImageModel: Decodable {
		
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
	}
	
}
