//
//  RemoteImagesLoader.swift
//  FeedAPIChallenge
//
//  Created by Ivan Ornes on 10/1/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteImagesLoader {
	
	internal static func getImages(_ data: Data) throws -> [FeedImage] {
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return [] }
		return (dictionary["items"] as? [[String: Any]] ?? []).compactMap(RemoteImage.init).map { $0.feedImage }
	}
}
