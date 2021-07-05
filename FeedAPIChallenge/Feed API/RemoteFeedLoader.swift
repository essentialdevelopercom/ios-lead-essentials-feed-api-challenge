//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	typealias Result = Swift.Result<Data, Error>

	private struct ResponseRootEntity: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
	}

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
		client.get(from: url) { httpClientResult in
			let result = Self.httpClientResult2FeedLoaderResult(httpClientResult)
			switch result
			{
			case .success(let responseData):
				do {
					let _ = try JSONDecoder().decode(ResponseRootEntity.self, from: responseData)
					completion(.success([]))
				} catch {
					completion(.failure(Error.invalidData))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private static func httpClientResult2FeedLoaderResult(_ httpClientResult: HTTPClient.Result) -> Result {
		let feedLoaderResult = httpClientResult.mapError { _ in Error.connectivity }
			.flatMap { (responseData, httpResponse) -> Swift.Result<Data, Error> in
				guard httpResponse.isStatusOK else {
					return .failure(Error.invalidData)
				}
				return .success(responseData)
			}
		return feedLoaderResult
	}
}

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }

	var isStatusOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
}
