//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Marius Cotfas on 25/02/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
		
	private struct JSONRoot: Decodable {
		let items: [Item]
		
		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var item: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}	
	
	internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard
			response.statusCode == 200,
			let jsonRoot = try? JSONDecoder().decode(JSONRoot.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(jsonRoot.feed)
	}
	
}
