//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by George Solorio on 10/7/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
   
   private struct Root: Decodable {
      let items: [Image]
   }

   private struct Image: Decodable {
      
      let image_id: UUID
      let image_desc: String?
      let image_loc: String?
      let image_url: URL
      
      var image: FeedImage {
         return FeedImage(
            id: image_id,
            description: image_desc,
            location: image_loc,
            url: image_url)
      }
   }
   
   private static var OK_200 = 200
   
   static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
      
      guard response.statusCode == OK_200 else {
         throw RemoteFeedLoader.Error.invalidData
      }
      
      let root = try JSONDecoder().decode(Root.self, from: data)
      return root.items.map { $0.image }
   }
}
