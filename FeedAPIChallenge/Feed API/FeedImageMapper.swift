//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Пильтенко Роман on 11.02.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper: Decodable {
	private let items: [ImageItem]
	
	private var imageItems: [FeedImage] {
		items.map { FeedImage(id: $0.id,
							  description: $0.description,
							  location: $0.location,
							  url: $0.url)}
	}
	
	private struct ImageItem: Decodable {
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
	}
	
	private static var OK_200: Int { return 200 }
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Self.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.imageItems)
	}
}
