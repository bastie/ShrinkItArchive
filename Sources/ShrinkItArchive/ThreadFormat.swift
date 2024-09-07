import JavApi

/**
 * Define and decode the thread_format field.
 * @author robgreene@users.sourceforge.net
 *
 * @author Sebastian Ritter <bastie@users.noreply.github.com> for Swift
 */
public enum ThreadFormat : CaseIterable {
  case UNCOMPRESSED(format:Int=0x0000, name:String="Uncompressed")
  case HUFFMAN_SQUEEZE(format:Int=0x0001, name:String="Huffman Squeeze")
  case DYNAMIC_LZW1(format:Int=0x0002, name:String="Dynamic LZW/1")
  case DYNAMIC_LZW2(format:Int=0x0003, name:String="Dynamic LZW/2")
  case UNIX_12BIT_COMPRESS(format:Int=0x0004, name:String="Unix 12-bit Compress")
  case UNIX_16BIT_COMPRESS(format:Int=0x0005, name:String="Unix 16-bit Compress")
  
  public static var allCases: [ThreadFormat] {
    return [
      .UNCOMPRESSED(),
      .HUFFMAN_SQUEEZE(),
      .DYNAMIC_LZW1(),
      .DYNAMIC_LZW2(),
      .UNIX_12BIT_COMPRESS(),
      .UNIX_16BIT_COMPRESS()
    ]
  }
  
	/** Associate the hex codes with the enum */
  public var getThreadFormat : Int {
    get {
      switch self {
      case .UNCOMPRESSED(let format, _):
        return format
      case .HUFFMAN_SQUEEZE(let format, _):
        return format
      case .DYNAMIC_LZW1(let format, _):
        return format
      case .DYNAMIC_LZW2(let format, _):
        return format
      case .UNIX_12BIT_COMPRESS(let format, _):
        return format
      case .UNIX_16BIT_COMPRESS(let format, _):
        return format
      }
    }
  }
  public var getName : String {
    get {
      switch self {
      case .UNCOMPRESSED(_, let name):
        return name
      case .HUFFMAN_SQUEEZE(_, let name):
        return name
      case .DYNAMIC_LZW1(_, let name):
        return name
      case .DYNAMIC_LZW2(_, let name):
        return name
      case .UNIX_12BIT_COMPRESS(_, let name):
        return name
      case .UNIX_16BIT_COMPRESS(_, let name):
        return name
      }
    }
  }

	/**
	 * Find the ThreadFormat.
	 * @throws IllegalArgumentException if the thread_format is unknown
	 */
	public static func find(_ threadFormat : Int) throws -> ThreadFormat{
		for f : ThreadFormat in allCases {
      if (threadFormat == f.getThreadFormat) {
        return f
      }
		}
		throw Throwable.IllegalArgumentException("Unknown thread_format of \(threadFormat)")
	}
}

extension ThreadFormat : Equatable {
  static public func == (lhs: ThreadFormat, rhs: ThreadFormat) -> Bool {
    return lhs.getName == rhs.getName && lhs.getThreadFormat == rhs.getThreadFormat
  }
}
