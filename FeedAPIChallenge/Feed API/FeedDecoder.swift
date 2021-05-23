//
//  FeedDecoder.swift
//  FeedAPIChallenge
//
//  Created by Karthik K Manoj on 23/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageRoot: Decodable {
	private let items: [FeedImageItem]

	private struct FeedImageItem: Decodable {
		private let imageID: String
		private let imageDescription: String?
		private let imageLocation: String?
		private let imageURL: String

		enum CodingKeys: String, CodingKey {
			case imageID = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}
	}
}
