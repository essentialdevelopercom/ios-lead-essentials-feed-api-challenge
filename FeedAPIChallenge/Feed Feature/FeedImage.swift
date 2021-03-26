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

public struct FeedImageMapper {
	struct Root: Codable {
		
		var items: [Item]
		
		var images: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	struct Item: Codable {
		public var id: UUID
		public var description: String?
		public var location: String?
		public var url: URL
		
		var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
