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
        completion(FeedItemMapper.map(data, from: response))
      case .failure:
        completion(.failure(RemoteFeedLoader.Error.connectivity))
      }
    }
  }
}

internal final class FeedItemMapper {
  struct Root: Decodable {
    let items: [Item]

    var feed: [FeedImage] {
      return items.map({ $0.item })
    }
  }

  struct Item: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL

    var item: FeedImage {
      return FeedImage(id: id, description: description, location: location, url: url)
    }
  }

  private static var OK_200: Int { return 200}

  internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
    guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else { return .failure(RemoteFeedLoader.Error.invalidData)}

    return .success(root.feed)
  }
}
