//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Onyekachi Ezeoke on 16/04/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private static var OK_200: Int { return 200 }
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success([])
	}
}
