//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
  case success(Data,HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
//	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
