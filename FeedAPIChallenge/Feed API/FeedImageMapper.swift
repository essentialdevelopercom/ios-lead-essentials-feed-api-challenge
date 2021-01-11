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
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
			  let imageItems = dictionary["items"] as? [[String: Any]] else { throw RemoteFeedLoader.Error.invalidData }
		return imageItems.compactMap(RemoteImage.init).map { $0.feedImage }
	}
}
