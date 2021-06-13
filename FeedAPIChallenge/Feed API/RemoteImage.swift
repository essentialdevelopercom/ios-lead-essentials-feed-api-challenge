//
//  RemoteImage.swift
//  FeedAPIChallenge
//
//  Created by Daniel Gallego Peralta on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
