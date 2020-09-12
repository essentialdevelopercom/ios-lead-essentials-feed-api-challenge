//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>
	
	func get(from url: URL, completion: @escaping (Result) -> Void)
}
