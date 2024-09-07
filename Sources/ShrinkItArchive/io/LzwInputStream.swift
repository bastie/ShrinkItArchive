import JavApi

/**
 * This is the generic Shrinkit LZW decompression algorithm.
 * It does not deal with the vagaries of the LZW/1 and LZW/2 data streams.
 * It does, however, deal with dictionary clears (0x100) and the 
 * <code>BitInputStream</code> bit sizes.
 *  
 * @author robgreene@users.sourceforge.net
 */
open class LzwInputStream : java.io.InputStream {
  private var `is` : BitInputStream
  private var dictionary : [[Int]]?
  private var outputBuffer : any java.util.Queue<Int> = ShrinkItArchiveIntQueue() /* ConcurrentLinkedQueue<Integer>();*/
	private var newBuffer = true;
	// See Wikipedia entry on LZW for variable naming
  private var k : Int = 0
  private var w : [Int]?
  private var entry : [Int]?
	
	/**
	 * Create the <code>LzwInputStream</code> based on the given
	 * <code>BitInputStream</code>.
	 * @see BitInputStream
	 */
  public init(_ bitInputStream : BitInputStream ) {
		self.is = bitInputStream
	}

	/**
	 * Answer with the next byte from the (now) decompressed input stream.
	 */
  open override func read() throws /*IOException*/ -> Int{
		if (outputBuffer.isEmpty()) {
      try fillBuffer()
		}
    return try outputBuffer.remove()
	}

	/**
	 * Fill the buffer up with some decompressed data.
	 * This may range from one byte to many bytes, depending on what is in the
	 * dictionary.
	 * @see <a href="http://en.wikipedia.org/wiki/Lzw">Wikipedia for the general algorithm</a>
	 */
	public func fillBuffer() throws /*IOException*/ {
		if (dictionary == nil) {
      self.is.setRequestedNumberOfBits(9)
			// Setup default dictionary for all bytes
      self.dictionary = [[Int]]()
      for i in 0..<256 {
        let content : [Int] = Array.init(repeating: 1, count: i)
        _ = self.dictionary!.add(content)
      }
      let content : [Int] = Array(repeating: 1, count: 0x100)  // 0x100 not used by NuFX
      _ = self.dictionary!.add(content)
		}
		if (newBuffer) {
			// Setup for decompression;
      k = try self.is.read()
			_ = try! outputBuffer.add(k)
      if (k == -1) {
        return
      }
			w = Array(repeating: k, count: 1)
			newBuffer = false
		}
		// LZW decompression
    k = try self.is.read()
		if (k == -1) {
			_ = try! outputBuffer.add(k)
			return
		}
		if (k == 0x100) {
			dictionary = nil
      self.is.setRequestedNumberOfBits(9)
			k = 0
			w = nil
			entry = nil
			newBuffer = true
      try fillBuffer()	// Warning: recursive call
			return
		}
		if (k < dictionary!.count) {
			entry = dictionary![k]
		} else if (k == dictionary?.count) {
			//entry = Arrays.copyOf(w, w.length+1);
			entry = Array(repeating: 0, count: w!.count+1)
      System.arraycopy(w!, 0, &entry!, 0, w!.count)
      entry![w!.count] = w![0]
		} else {
      throw java.io.Throwable.IOException("Invalid code of <\(k)> encountered");
		}
    for i in entry! {
      _ = try! outputBuffer.add(i)
    }
		//int[] newEntry = Arrays.copyOf(w, w.length+1);
    var newEntry : [Int] = Array(repeating: 0, count: w!.count+1)
    System.arraycopy(w!, 0, &newEntry, 0, w!.count)
    newEntry[w!.count] = entry![0]
    _ = self.dictionary!.add(newEntry)
		w = entry;
		// Exclusive-OR the current bitmask against the new dictionary size -- if all bits are
		// on, we'll get 0.  (That is, all 9 bits on is 0x01ff exclusive or bit mask of 0x01ff 
		// yields 0x0000.)  This tells us we need to increase the number of bits we're pulling
		// from the bit stream.
    if ((dictionary!.count ^ self.is.getBitMask()) == 0) {
      self.is.increaseRequestedNumberOfBits()
		}
	}
	
	/**
	 * Clear out the dictionary.  It will be rebuilt on the next call to
	 * <code>fillBuffer</code>.
	 */
	public func clearDictionary() {
    self.dictionary = nil
    self.is.setRequestedNumberOfBits(9)
    self.is.clearRemainingBitsOfData()
		try! outputBuffer.clear()
		k = 0
		w = nil
		entry = nil
		newBuffer = true
	}
	
	/**
	 * Provide necessary housekeeping to reset LZW stream between NuFX buffer changes.
	 * The dictionary is the only item that is not cleared -- that needs to be done
	 * explicitly since behavior between LZW/1 and LZW/2 differ. 
	 */
	public func clearData() {
    self.is.clearRemainingBitsOfData()
		try! outputBuffer.clear()
	}
}
