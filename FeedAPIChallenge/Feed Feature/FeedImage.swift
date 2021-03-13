//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Hashable {
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
}
// MARK: - Implement Decodable protocol
extension FeedImage: Decodable {
	enum FeedImageCodings: String, CodingKey {
		case id
		case description
		case location
		case url
	}
	// MARK: - Create a FeedImage object
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: FeedImageCodings.self)
		id = try container.decode(UUID.self, forKey: .id)
		description = try container.decode(String.self, forKey: .description)
		location = try container.decode(String.self, forKey: .location)
		url = try container.decode(URL.self, forKey: .url)
	}
}
