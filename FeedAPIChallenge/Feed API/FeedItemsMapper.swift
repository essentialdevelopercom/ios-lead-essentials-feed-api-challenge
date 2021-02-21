//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Saravanakumar S on 21/02/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
	typealias Error = RemoteFeedLoader.Error

	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		guard response.statusCode == 200,
			  let root = try? decoder.decode(Root.self, from: data) else {
			return .failure(Error.invalidData)
		}
		
		return .success(root.feedItems)
	}
}
