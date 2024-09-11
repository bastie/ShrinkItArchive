import XCTest
@testable import ShrinkItArchive

public class CRC16Test : XCTestCase {
	public func testTable() {
    let table : [Int] = CRC16.getTable();
		XCTAssertEqual(0, table[0]);
		XCTAssertEqual(0x1ef0, table[0xff]);
		print("CRC16 lookup table:");
    for i in 0..<256 {
      let hex = String(format: "%04x", table[i])
			print("\(hex) ", terminator: "");
      if ((i + 1) % 8 == 0) {
        print()
      }
		}
	}

	public func testUpdate()  {
    do {
      let crc16 = CRC16()
      crc16.update(try! "123456789".getBytes("UTF-8"))
      XCTAssertEqual(0x31c3, crc16.getValue())
      crc16.update(try! "ABCDEFGHIJKLMNOPQRSTUVWXYZ".getBytes("UTF-8"))
      XCTAssertEqual(0x92cc, crc16.getValue())
      crc16.update(try! "abcdefghijklmnopqrstuvwxyz".getBytes("UTF-8"))
      XCTAssertEqual(0xfc85, crc16.getValue())
      crc16.reset()
      crc16.update(try! "xxx123456789xxx".getBytes("UTF-8"), 3, 9)
      XCTAssertEqual(0x31c3, crc16.getValue())
    }
	}

	public func testVariousValues() {
		let crc16 = CRC16();
    let data : [UInt8] = [ 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, UInt8(0x80) ]
		crc16.update(data);
    XCTAssertEqual(0x2299, crc16.getValue())
	}
}
