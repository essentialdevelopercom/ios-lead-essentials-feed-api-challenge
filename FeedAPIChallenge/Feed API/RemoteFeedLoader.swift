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
		client.get(from: url) { [weak self] result in
			
			guard self != nil else { return }
			
			switch result {
			case .failure: completion(.failure(Error.connectivity))
			case let .success((data, response)):
				
				let mapper = RemoteFeedMapper()
				completion(mapper.map(response, data: data))
			}
		}
	}
}

private struct RemoteFeedMapper {
	private static let SuccessResponseCode = 200
	
	struct FeedRoot: Decodable {
		let items: [FeedImageDTO]
	}
	
	struct FeedImageDTO: Decodable {
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case location = "image_loc"
			case url = "image_url"
			case description = "image_desc"
		}
		
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
	}
	
	func map(_ response: HTTPURLResponse, data: Data) -> FeedLoader.Result {
		guard response.statusCode == RemoteFeedMapper.SuccessResponseCode,
			  let decoded = try? JSONDecoder().decode(FeedRoot.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(decoded.items.map { FeedImage(id: $0.id,
													  description: $0.description,
													  location: $0.location,
													  url: $0.url) })
	}
}
