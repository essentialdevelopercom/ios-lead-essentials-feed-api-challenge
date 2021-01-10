//
//  FeedItemMapper.swift
//  FeedAPIChallenge
//
//  Created by ilhan sarı on 10.01.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

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
