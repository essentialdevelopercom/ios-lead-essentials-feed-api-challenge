//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Hashable, Decodable {
	public let image_id: UUID
	public let image_desc: String?
	public let image_loc: String?
	public let image_url: URL
	
	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.image_id = id
		self.image_desc = description
		self.image_loc = location
		self.image_url = url
	}
}

public struct Images: Hashable, Decodable {
	public let items: [FeedImage]
}
