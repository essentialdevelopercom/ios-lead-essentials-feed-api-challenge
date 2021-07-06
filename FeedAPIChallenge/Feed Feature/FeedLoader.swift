//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], RemoteFeedLoader.Error>

	func load(completion: @escaping (Result) -> Void)
}
