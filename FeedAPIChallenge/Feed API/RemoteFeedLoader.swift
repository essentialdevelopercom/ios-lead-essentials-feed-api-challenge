//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	typealias RemoteFeedLoaderResult = Swift.Result<Data, Error>

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
			let feedLoaderResult = Self.httpClientResult2RemoteFeedLoaderResult(httpClientResult)
			switch feedLoaderResult
			{
			case .success(let responseData):
				let result = Self.responseData2FeedLoaderResult(responseData: responseData)
				completion(result)
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private static func httpClientResult2RemoteFeedLoaderResult(_ httpClientResult: HTTPClient.Result) -> RemoteFeedLoaderResult {
		let feedLoaderResult = httpClientResult.mapError { _ in Error.connectivity }
			.flatMap { (responseData, httpResponse) -> Swift.Result<Data, Error> in
				guard httpResponse.isStatusOK else {
					return .failure(Error.invalidData)
				}
				return .success(responseData)
			}
		return feedLoaderResult
	}

	private static func responseData2FeedLoaderResult(responseData: Data) -> FeedLoader.Result {
		var result: FeedLoader.Result
		do {
			let _ = try JSONDecoder().decode(ResponseRootEntity.self, from: responseData)
			result = .success([])
		} catch {
			result = .failure(Error.invalidData)
		}
		return result
	}
}

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }

	var isStatusOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
}
