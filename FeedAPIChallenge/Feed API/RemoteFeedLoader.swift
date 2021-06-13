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
			switch result {
			case let .success((receivedData, response)):

				if response.statusCode == 200 {
					if let _ = self?.mapping(receivedData) {
					} else {
						completion(.failure(Error.invalidData))
					}
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}

	//MARK: - HELPER

	private func mapping(_ data: Data) -> [Item]? {
		do {
			let root = try JSONDecoder().decode(Root.self, from: data)
			return root.items
		} catch {
			return nil
		}
	}
}
