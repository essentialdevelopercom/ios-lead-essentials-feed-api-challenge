//
//  Item.swift
//  FeedAPIChallenge
//
//  Created by Romeo Flauta on 4/5/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public struct Root: Decodable {
	let items: [Item]
	var feed: [FeedImage] {
		return items.map{$0.item}
	}
}

//internal representation of FeedItem but for the API module
public struct Item: Decodable {
	let imageId: String
	let imageDesc: String?
	let imageLoc: String?
	let imageUrl: URL
	
	var item: FeedImage {
		return FeedImage(id: UUID(uuidString: imageId)!, description: imageDesc, location: imageLoc, url: imageUrl)
	}
}
