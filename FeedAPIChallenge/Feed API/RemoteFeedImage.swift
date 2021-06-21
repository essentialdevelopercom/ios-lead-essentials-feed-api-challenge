//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Luis Zapata on 17-06-21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteFeedImageResponse: Decodable {
	let items: [RemoteFeedImage]?
}

internal struct RemoteFeedImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
