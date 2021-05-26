//
//  Root.swift
//  FeedAPIChallenge
//
//  Created by Darren Findlay on 26/05/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct Root: Decodable {
	let items: [RemoteFeedImage]
}
