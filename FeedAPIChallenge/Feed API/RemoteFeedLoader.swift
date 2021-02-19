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
			case .failure(_):
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
					return
				}
				
				do {
					let loaderResponse = try JSONDecoder().decode(FeedLoaderResponse.self, from: data)
					let feedImages = try FeedLoaderMapper().map(loaderResponse)
					completion(.success(feedImages))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
	
	private struct FeedLoaderMapper {
		func map(_ response: FeedLoaderResponse) throws -> [FeedImage] {
			try response.items.map { item in
				guard let id = UUID(uuidString: item.id),
					  let url = URL(string: item.url) else {
					throw Error.invalidData
				}
				
				return FeedImage(
					id: id,
					description: item.description,
					location: item.location,
					url: url
				)
			}
		}
	}
	
	private struct FeedLoaderResponse: Decodable {
		let items: [ResponseItem]
	}
	
	private struct ResponseItem: Decodable {
		let id: String
		let description: String?
		let location: String?
		let url: String
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		
	}
}



