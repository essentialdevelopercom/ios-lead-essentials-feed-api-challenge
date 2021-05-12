//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private var OK_200: Int {
		return 200
	}

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
			guard let self = self else {
				return
			}

			switch result {
			case .success((let data, let response)):
				guard response.statusCode == self.OK_200 else {
					completion(.failure(Error.invalidData))
					return
				}

				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
						if let items = json["items"] as? [[String: Any]] {
							if items.isEmpty {
								completion(.success([]))
								return
							}

							var result: [FeedImage] = []
							for item in items {
								guard let idString = item["image_id"] as? String,
								      let uuid = UUID(uuidString: idString),
								      let urlString = item["image_url"] as? String,
								      let url = URL(string: urlString) else {
									completion(.failure(Error.invalidData))
									return
								}

								let description = item["image_desc"] as? String
								let location = item["image_loc"] as? String

								result.append(FeedImage(id: uuid, description: description, location: location, url: url))
							}

							completion(.success(result))
						}
					}
				} catch {
					completion(.failure(Error.invalidData))
				}

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
