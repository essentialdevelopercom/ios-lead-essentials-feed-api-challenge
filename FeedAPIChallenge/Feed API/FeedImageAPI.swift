//
//  FeedImageAPI.swift
//  FeedAPIChallenge
//
//  Created by Hoff Silva on 23/05/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageAPI: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
