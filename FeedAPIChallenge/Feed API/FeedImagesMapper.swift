//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Arup Sarkar on 5/4/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [Item]
		var feed: [FeedImage] {
			return items.map({ $0.item })
		}
	}

	private struct Item: Decodable {
		let id: UUID //Required
		let description: String? //Optional String
		let location: String? //optional
		let url: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		do {
			let result: Root
			try result = JSONDecoder().decode(Root.self, from: data)
			print(result)
		} catch DecodingError.keyNotFound(let key, let context) {
			Swift.print("Error: could not find key \(key) in JSON: \(context.debugDescription)")
		} catch DecodingError.valueNotFound(let type, let context) {
			Swift.print("Error: could not find type \(type) in JSON: \(context.debugDescription)")
		} catch DecodingError.typeMismatch(let type, let context) {
			Swift.print("Error: type mismatch for type \(type) in JSON: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			Swift.print("Error: data found to be corrupted in JSON: \(context.debugDescription)")
		} catch let error as NSError {
			NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
		}

		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
