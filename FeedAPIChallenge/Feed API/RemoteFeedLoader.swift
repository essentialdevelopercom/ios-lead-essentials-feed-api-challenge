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
		client.get(from: url) { [unowned self] result in
			switch result {
			
			case .failure:
				completion(.failure(Error.connectivity))
				
			case .success(let(data, response)):
				
				guard response.statusCode == 200,
					  let images = images(from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				
				completion(.success(images))
			}
		}
	}
	
	private func images(from data: Data) -> [FeedImage]? {
		try? JSONDecoder().decode([FeedImage].self, from: data)
	}
}
