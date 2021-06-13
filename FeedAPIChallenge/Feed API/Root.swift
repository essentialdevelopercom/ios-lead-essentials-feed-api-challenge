//
//  Root.swift
//  FeedAPIChallenge
//
//  Created by Gordon Feng on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

public struct Root: Codable {
	public let items: [Item]
	public var feedImages: [FeedImage] {
		return items.map({ $0.feedImage })
	}

	public init(items: [Item]) {
		self.items = items
	}
}

public struct Item: Codable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
	public var feedImage: FeedImage {
		return FeedImage(id: self.id,
		                 description: self.description,
		                 location: self.location,
		                 url: self.url)
	}

	public init?(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
