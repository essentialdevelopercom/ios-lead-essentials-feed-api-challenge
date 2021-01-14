//
//  ItemsToFeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Ana Nogal on 14/01/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct ItemsToFeedImagesMapper {
  private static let STATUS_CODE_OK = 200

  private struct Items: Decodable {
    let items: [Item]

    var feedImages: [FeedImage] {
      items.map { item in item.feedImage }
    }
  }

  private struct Item: Decodable {
    let image_id: UUID
    let image_desc: String?
    let image_loc: String?
    let image_url: URL

    var feedImage: FeedImage {
      FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
    }
  }

  static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
    guard response.statusCode == STATUS_CODE_OK, let items = try? JSONDecoder().decode(Items.self, from: data) else {
      return .failure(RemoteFeedLoader.Error.invalidData)
    }
    return .success(items.feedImages)
  }
}
