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
			
			guard let _ = self else { return }
			
			switch result {
			case .failure: completion(.failure(Error.connectivity))
			case .success(let successResult):
				
				let response = successResult.1
				let data = successResult.0
				
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
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: FeedImageDTO.Keys.self)
			id = try container.decode(UUID.self, forKey: .id)
			description = try container.decodeIfPresent(String.self, forKey: .description)
			location = try container.decodeIfPresent(String.self, forKey: .location)
			url = try container.decode(URL.self, forKey: .url)
		}
	}
	
	func map(_ response: HTTPURLResponse, data: Data) -> FeedLoader.Result {
		guard response.statusCode == RemoteFeedMapper.SuccessResponseCode else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		do {
			let decoded = try JSONDecoder().decode(FeedRoot.self, from: data)
			return .success(decoded.items.map { FeedImage(id: $0.id,
														  description: $0.description,
														  location: $0.location,
														  url: $0.url) })
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
