//
//  FeedLoaderMapper.swift
//  FeedAPIChallenge
//
//  Created by sassi walid on 01/03/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public struct FeedLoaderMapper {

	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedImage] {
			return items.map{ $0.item }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}
	}
	static var ok_200: Int { return 200 }
	
	static  func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == ok_200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = [FeedImage]()
		return .success(items)
	}
}

