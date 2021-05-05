//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Arup Sarkar on 5/4/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		return .failure(RemoteFeedLoader.Error.invalidData)
	}
}
