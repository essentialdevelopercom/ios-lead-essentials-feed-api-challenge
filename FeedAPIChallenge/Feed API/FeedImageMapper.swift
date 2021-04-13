//
//  RemoteFeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Vladimir Jeremic on 4/13/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private static let OK_200_HTTP_SATUS_CODE = 200

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard FeedImageMapper.OK_200_HTTP_SATUS_CODE == response.statusCode,
		      let _ = try? JSONSerialization.jsonObject(with: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success([])
	}
}
