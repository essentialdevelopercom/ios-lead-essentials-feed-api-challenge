//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private static let OK_200 = 200

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    client.get(from: url) { (result) in
      switch result {
      case let .success((data, response)):
        completion(FeedImageMapper.map(data: data, response: response))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
}

internal final class FeedImageMapper {
  private struct Root: Decodable {
    private let items: [Image]

    var feed: [FeedImage] {
      return items.map { $0.feedImage }
    }
  }

  private struct Image: Decodable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL

    var feedImage: FeedImage {
      return FeedImage(id: id, description: description, location: location, url: url)
    }

    private enum CodingKeys: String, CodingKey {
      case id = "image_id"
      case description = "image_desc"
      case location = "image_loc"
      case url = "image_url"
    }
  }

  private static var OK_200: Int { return 200 }

  internal static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
    guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
      return .failure(RemoteFeedLoader.Error.invalidData)
    }
    return .success(root.feed)
  }
}
