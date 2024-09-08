import JavApi

/**
 * This is the generic Shrinkit LZW compression algorithm.
 * It does not deal with the vagaries of the LZW/1 and LZW/2 data streams.
 *  
 * @author robgreene@users.sourceforge.net
 */
public class LzwOutputStream : java.io.OutputStream {
  private var os : BitOutputStream
  private var dictionary : [ByteArray : Int?] = [:]
  private var w : [Int] = [Int]()
  private var nextCode : Int = 0x101;
	
	/**
	 * This simple class can be used as a key into a Map.
	 *  
	 * @author robgreene@users.sourceforge.net
	 */
  fileprivate struct ByteArray : Hashable {
    static func == (lhs: LzwOutputStream.ByteArray, rhs: LzwOutputStream.ByteArray) -> Bool {
      return lhs.equals(rhs)
    }
    func hash(into hasher: inout Hasher) {
      data.forEach { hasher.combine($0) }
    }

		/** Data being managed. */
    private var data : [Int]
		/** The computed hash code -- CRC-16 for lack of imagination. */
    private var hashCodeValue : Int
		
    public init(_ d : Int) {
      self.data = [d]
      var crc = CRC16()
      for b in data {
        crc.update(b)
      }
      hashCodeValue = Int(crc.getValue())
		}
    public init(_ data : [Int]) {
			self.data = data
			var crc = CRC16()
      for b in data {
        crc.update(b)
      }
			hashCodeValue = Int(crc.getValue())
		}
    
    public func equals(_ obj : Any) -> Bool{ // TODO: Swift is easier with self.data == obj.data... - first commit bad Java port
      guard obj is LzwOutputStream.ByteArray else {
        return false
      }
      let ba : ByteArray = obj as! LzwOutputStream.ByteArray
      if (data.length != ba.data.length) {
        return false
      }
      for i in 0..<data.length {
        if (data[i] != ba.data[i]) {
          return false
        }
			}
			return true
		}
		public func hashCode() -> Int {
			return hashCodeValue
		}
	}
	
  public init(_ os : BitOutputStream) {
		self.os = os;
	}

  public override func write(_ _c : Int) throws /*IOException*/ {
    var c = _c
    if (dictionary.isEmpty) {
      for i in 0..<256 {
        dictionary[ByteArray(i)] = i
      }
      dictionary [ByteArray(0x100)] = nil	// just to mark its spot
		}
		c &= 0xff
    var wc : [Int] = Array(repeating: 0, count: w.length + 1)
    if (w.length > 0) {
      System.arraycopy(w, 0, &wc, 0, w.length)
    }
		wc[wc.length-1] = c;
		if (dictionary.containsKey( ByteArray(wc))) {
			w = wc;
		} else {
			dictionary[ByteArray(wc)] = nextCode
      nextCode += 1
      try os.write(dictionary[ByteArray(w)]!!)
			w = [c]
		}
		// Exclusive-OR the current bitmask against the new dictionary size -- if all bits are
		// on, we'll get 0.  (That is, all 9 bits on is 0x01ff exclusive or bit mask of 0x01ff 
		// yields 0x0000.)  This tells us we need to increase the number of bits we're writing
		// to the bit stream.
		if ((dictionary.count ^ os.getBitMask()) == 0) {
			os.increaseRequestedNumberOfBits();
		}
	}

  public override func flush() throws /*IOException*/ {
    try os.write(dictionary[ByteArray(w)]!!)
	}
	
  public override func close() throws /*IOException*/ {
    try flush()
    try os.flush()
    try os.close()
	}
}
