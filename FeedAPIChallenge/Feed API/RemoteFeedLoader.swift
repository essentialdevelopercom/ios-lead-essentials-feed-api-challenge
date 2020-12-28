//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success((let data, let response)):
				completion(FeedImageMapper.map(data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

}

class FeedImageMapper {
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		
		let imageID: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageURL: URL
		
		var item: FeedImage {
			return FeedImage(id: imageID,
							 description: imageDescription,
							 location: imageLocation,
							 url: imageURL)
		}
		
		enum CodingKeys: String, CodingKey {
			case imageID = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}
		
	}
	
	private static let OK_STATUS = 200
	
	internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		if response.statusCode == OK_STATUS,
		   let decodedList = try? JSONDecoder().decode(Root.self, from: data) {
			return .success(decodedList.feed)
		}
		return .failure(RemoteFeedLoader.Error.invalidData)
	}
	
}
