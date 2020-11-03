//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by SUNG HAO LIN on 2020/11/3.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

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
