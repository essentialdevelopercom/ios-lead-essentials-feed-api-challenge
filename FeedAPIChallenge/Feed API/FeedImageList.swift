//
//  FeedImageList.swift
//  FeedAPIChallenge
//
//  Created by Ajoy Kumar on 14/06/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct ImageList: Decodable {
	let items: [Images]
}

internal struct Images: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL

	var image: FeedImage {
		FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}
