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

	private var OK_200: Int { return 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success((data, httpURLResponse)):

				if httpURLResponse.statusCode != self.OK_200 {
					completion(.failure(Error.invalidData))
					return
				}

				do {
					let _ = try JSONDecoder().decode([RemoteFeedImage].self, from: data)
				} catch {
					completion(.failure(Error.invalidData))
					return
				}

				completion(.success([]))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}

	private class RemoteFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		init(id: UUID, description: String?, location: String?, url: URL) {
			self.id = id
			self.description = description
			self.location = location
			self.url = url
		}
	}
}
