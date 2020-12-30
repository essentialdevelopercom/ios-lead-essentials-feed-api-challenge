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
			case let .success((data, response)):
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				
				if response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) {
					completion(.success(root.items.map { $0.item }))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Image]
}

private struct Image: Decodable {
	let imageId: UUID
	let imageDesc: String?
	let imageLoc: String?
	let imageUrl: URL
	
	var item: FeedImage {
		return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
	}
}
