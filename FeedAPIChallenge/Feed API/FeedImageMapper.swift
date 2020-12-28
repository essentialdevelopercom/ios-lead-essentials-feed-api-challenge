//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Alexander Nikolaychuk on 28.12.2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageMapper {
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		
		let imageID: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageURL: URL
		
		var item: FeedImage {
			return FeedImage(id: imageID,
							 description: imageDescription,
							 location: imageLocation,
							 url: imageURL)
		}
		
		enum CodingKeys: String, CodingKey {
			case imageID = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}
		
	}
	
	private static let OK_STATUS = 200
	
	internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		if response.statusCode == OK_STATUS,
		   let decodedList = try? JSONDecoder().decode(Root.self, from: data) {
			return .success(decodedList.feed)
		}
		return .failure(RemoteFeedLoader.Error.invalidData)
	}
	
}
