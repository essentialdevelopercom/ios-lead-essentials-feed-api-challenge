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

	public init(items: [Item]) {
		self.items = items
	}
}

public struct Item: Codable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL

	public init?(id: String, description: String?, location: String?, url: String) {
		guard let id = UUID(uuidString: id),
		      let url = URL(string: url) else {
			return nil
		}
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
