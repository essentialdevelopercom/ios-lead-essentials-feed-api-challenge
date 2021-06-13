//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Daniel Gallego Peralta on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper {
	private static let OK_200 = 200

	private struct GroupItem: Decodable {
		let items: [RemoteImage]
	}

	static func getResult(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let items = FeedImageMapper.decode(from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(items)
	}

	static private func decode(from data: Data) -> [FeedImage]? {
		guard let groupItem = try? JSONDecoder().decode(GroupItem.self, from: data) else {
			return nil
		}

		return mapRemoteImages(groupItem.items)
	}

	static private func mapRemoteImages(_ items: [RemoteImage]) -> [FeedImage] {
		return items.map { remoteImage in
			return FeedImage(
				id: remoteImage.id,
				description: remoteImage.description,
				location: remoteImage.location,
				url: remoteImage.url)
		}
	}
}
