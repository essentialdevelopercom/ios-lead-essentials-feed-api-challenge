//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Stuart on 11/03/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation


struct Root: Decodable {
	
	let images: [Image]
	
	var feed: [FeedImage] {
		images.map { $0.image }
	}
}

struct Image: Decodable {
	public let image_id: UUID
	public let image_desc: String?
	public let image_loc: String?
	public let image_url: URL
	
	var image: FeedImage {
		FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}
