import XCTest
@testable import ShrinkItArchive

import JavApi
import Foundation

public class TestHelper {
	private init() {
		// Prevent construction
	}
	
	public static func checkDate(_ streamData : [UInt8], _ actual : java.util.Date) throws {
		let lebis = LittleEndianByteInputStream(streamData)
    XCTAssertEqual(try! lebis.readDate(), actual)
	}
}
