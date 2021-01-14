//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Alok Subedi on 13/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Image]
		
		var feedItems: [FeedImage] {
			items.map { $0.feedImage }
		}
	}
	
	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	static func map( _ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.isSuccessful(), let root = try? JSONDecoder().decode(Root.self, from: data) {
			return .success(root.feedItems)
		}
		return .failure(RemoteFeedLoader.Error.invalidData)
	}
}

private extension HTTPURLResponse {
	private var successStatusCode: Int {
		200
	}
	
	func isSuccessful() -> Bool {
		return self.statusCode == successStatusCode
	}
}
