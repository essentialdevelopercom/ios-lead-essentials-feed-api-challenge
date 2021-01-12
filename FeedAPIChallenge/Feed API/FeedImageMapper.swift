//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Ivan Ornes on 10/1/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
	
	internal static func map(_ data: Data) throws -> [FeedImage] {
		let response = try JSONDecoder().decode(RemoteImageResponse.self, from: data)
		return response.feedItems
	}
}
