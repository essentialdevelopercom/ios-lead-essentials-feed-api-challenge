//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Decodable, Hashable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
	
	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
	
	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
	
	public init(from decoder:Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(UUID.self, forKey: .id)
		description = try values.decode(String.self, forKey: .description)
		location = try values.decode(String.self, forKey: .description)
		url = try values.decode(URL.self, forKey: .url)
	}
}

