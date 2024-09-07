import JavApi


/**
 * A simple class to hide the source of byte data.
 * @author robgreene@users.sourceforge.net
 */
public class LittleEndianByteInputStream : java.io.InputStream /*implements ByteConstants*/ {
  private var inputStream : java.io.InputStream
  private var bytesRead : Int64 = 0
  private var crc : CRC16 = CRC16()

	/**
	 * Construct a LittleEndianByteInputStream from an InputStream.
	 */
  public init (_ inputStream : java.io.InputStream) {
		self.inputStream = inputStream;
	}
	/**
	 * Construct a LittleEndianByteInputStream from a byte array.
	 */
  public init(_ data : [UInt8]) {
    self.inputStream = java.io.ByteArrayInputStream(data);
	}

	/**
	 * Get the next byte.
	 * Returns -1 if at end of input.
	 * Note that an unsigned byte needs to be returned in a larger container (ie, a short or int or long).
	 */
  public override func read() throws -> Int /*IOException*/ {
    let b : Int = try inputStream.read();
		if (b != -1) {
			crc.update(b)
			bytesRead += 1
		}
		return b;
	}
	/**
	 * Get the next byte and fail if we are at EOF.
	 * Note that an unsigned byte needs to be returned in a larger container (ie, a short or int or long).
	 */
	public func readByte() throws -> Int /*IOException*/ {
    let i : Int = try read()
    if (i == -1) {
      throw java.io.Throwable.IOException("Expecting a byte but at EOF")
    }
		return i
	}
	/**
	 * Get the next set of bytes as an array.
	 * If EOF encountered, an IOException is thrown.
	 */
  public func readBytes(_ bytes : Int) throws -> [UInt8] /*IOException*/ {
    var data : [UInt8] = Array(repeating: 0, count: bytes)
    var read : Int = try inputStream.read(&data);
    bytesRead += Int64(read);
		// In the case where we have a zero-byte file, 'read' stays at -1, which is not correct.  Fix it.
		if ((bytes == 0) && (read == -1)) {
			read = 0;
		}
		if (read < bytes) {
      throw java.io.Throwable.IOException("Requested \(bytes) bytes, but \(read) read")
		}
		crc.update(data);
		return data;
	}

	/**
	 * Test the beginning of the data stream for a magic signature, for up to a total
	 * of 2k bytes of leading garbage
	 */
	public func seekFileType() throws -> Int /*IOException*/ {
    return try seekFileType(6)
	}
	/**
	 * Test the beginning of the data stream for a magic signature, specifying the
	 * maximum size of a signature to test for
	 */
  public func seekFileType(_ max : Int) throws -> Int /*IOException*/ {
    var data : [UInt8] = Array(repeating: 0, count: 2048)
		var testNUFILE = Array(repeating: 0, count: 6)
		var testNUFX = Array(repeating: 0, count: 4)
		var testBXY = Array(repeating: 0, count: 3)
		var type = 0
    var pos = 0
    for i in 0..<data.length {
			data[i] = 0;
		}
    for i in 0..<max {
      data[i] = UInt8(try readByte())
		}
		while (pos < data.length-max) {
			if (max == 6) {
        System.arraycopy(data, pos, &testNUFILE, 0, ByteConstants.NUFILE_ID.length);
        if zip(testNUFILE, ByteConstants.NUFILE_ID).allSatisfy({ $0 == $1 }) {
					type = NuFileArchive.NUFILE_ARCHIVE
					break
				}
			}
      System.arraycopy(data, pos, &testNUFX, 0, ByteConstants.NUFX_ID.length)
      System.arraycopy(data, pos, &testBXY, 0, ByteConstants.BXY_ID.length)
      if zip(testNUFX, ByteConstants.NUFX_ID).allSatisfy({ $0 == $1 }) {
				type = NuFileArchive.NUFX_ARCHIVE
				break;
      } else if zip(testBXY, ByteConstants.BXY_ID).allSatisfy({ $0 == $1 }) {
				type = NuFileArchive.BXY_ARCHIVE
				break;
			}
      data[pos+max] = UInt8 (try readByte())
			pos += 1
		}
		return type;
	}
	/**
	 * Read the two bytes in as a "Word" which needs to be stored as a Java int.
	 */
	public func readWord() throws -> Int /*IOException*/ {
    return (try readByte() | readByte() << 8) & 0xffff;
	}
	/**
	 * Read the two bytes in as a "Long" which needs to be stored as a Java long.
	 */
	public func readLong() throws -> Int64 /*IOException*/ {
    let a : Int64 = Int64(try readByte())
    let b : Int64 = Int64(try readByte())
    let c : Int64 = Int64(try readByte())
    let d : Int64 = Int64(try readByte())
		return Int64 (a | b<<8 | c<<16 | d<<24);
	}
	/**
	 * Read the TimeRec into a Java Date object.
	 * Note that years 00-39 are assumed to be 2000-2039 per the NuFX addendum.
	 * @see <a href="http://www.nulib.com/library/nufx-addendum.htm">NuFX addendum</a>
	 */
  public func readDate() throws -> java.util.Date? /*IOException*/ {
    let data : [UInt8] = try readBytes(ByteConstants.TIMEREC_LENGTH);
    if zip(ByteConstants.TIMEREC_NULL, data).allSatisfy({ $0 == $1 })  {
      return nil
    }
    var year : Int = Int(data[ByteConstants.TIMEREC_YEAR])+1900;
    if (year < 1940) {
      year += 100
    }
    let gc = java.util.GregorianCalendar (
      year,
      data[ByteConstants.TIMEREC_MONTH]/*-1*/, // Basties Note: remove -1, did not know why implemented. The NuFX file format like Java Gregorian Calendar take zero for January
      data[ByteConstants.TIMEREC_DAY],
      data[ByteConstants.TIMEREC_HOUR],
      data[ByteConstants.TIMEREC_MINUTE],
      data[ByteConstants.TIMEREC_SECOND])
		return gc.getTime();
	}
	
	/**
	 * Reset the CRC-16 to $0000.
	 */
	public func resetCrc() {
		crc.reset();
	}
	/**
	 * Get the current CRC-16 value.
	 */
	public func getCrcValue() -> Int64 {
		return crc.getValue();
	}
	
	/**
	 * Answer with the total number of bytes read.
	 */
	public func getTotalBytesRead() -> Int64 {
		return bytesRead;
	}
  
  open override func available() throws -> Int {
    return try self.inputStream.available()
  }
}
