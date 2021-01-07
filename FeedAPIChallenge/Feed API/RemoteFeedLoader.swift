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
		client.get(from: URL(string: "https://a-given-url.com")!) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(FeedImagesMapper.map(data, from: response))
			}
		}
	}
}

private final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Image]
		
		var feedImages: [FeedImage] { items.map { $0.feedImage } }
	}

	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		var feedImage: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.isValid(),
			  let root: Root = jsonDecode(from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
	
	private static func jsonDecode<T: Decodable>(from data: Data) -> T? {
		return try? JSONDecoder().decode(T.self, from: data)
	}
}

private extension HTTPURLResponse {
	private static var StatusCodeSuccess = 200
	
	func isValid() -> Bool {
		return statusCode == HTTPURLResponse.StatusCodeSuccess
	}
}
