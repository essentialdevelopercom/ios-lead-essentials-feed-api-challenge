//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Caio Ortu on 2/22/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
	 
	 let items: [Image]
	 
	 var images: [FeedImage] {
		 items.map { $0.image }
	 }
	 
	 struct Image: Decodable {
		 let id: UUID
		 let description: String?
		 let location: String?
		 let url: URL
		 
		 var image: FeedImage {
			 FeedImage(id: id, description: description, location: location, url: url)
		 }
		 
		 enum CodingKeys: String, CodingKey {
			 case id = "image_id"
			 case description = "image_desc"
			 case location = "image_loc"
			 case url = "image_url"
		 }
	 }
 }
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.images)
	}
}

