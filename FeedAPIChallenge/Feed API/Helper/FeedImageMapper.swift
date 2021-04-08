//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Carlos Marcelo Tonisso Junior on 02/04/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct FeedImageMapper {
	
	private struct Root: Codable {
		internal var items: [Item]
		internal var images: [FeedImage] {
			return items.map(\.item)
		}
	}
	
	private struct Item: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		internal var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	internal static func map(from data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.images)
	}

}
