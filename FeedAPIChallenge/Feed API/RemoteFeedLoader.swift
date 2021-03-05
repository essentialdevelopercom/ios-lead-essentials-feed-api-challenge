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
				
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				
				let data = successResult.0
				
				do {
					let topKey = "items"
					let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
					guard dict?.keys.firstIndex(of: topKey) != nil,
						  let items = dict?[topKey] else {
						completion(.failure(Error.invalidData))
						return
					}
					
					let serializedData = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
					let decoded = try JSONDecoder().decode([FeedImage].self, from: serializedData)
					completion(.success(decoded))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
