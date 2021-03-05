//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Hashable, Decodable {
	enum Keys: String, CodingKey {
		case id = "image_id"
		case location = "image_loc"
		case url = "image_url"
		case description = "image_desc"
	}
	
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
	
	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: FeedImage.Keys.self)
		id = try container.decode(UUID.self, forKey: .id)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		location = try container.decodeIfPresent(String.self, forKey: .location)
		url = try container.decode(URL.self, forKey: .url)
	}
}
