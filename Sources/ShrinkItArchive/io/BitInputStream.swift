import JavApi

/**
 * The BitInputStream allows varying bit sizes to be pulled out of the
 * wrapped InputStream.  This is useful for LZW type compression algorithms
 * where 9-12 bit codes are used instead of the 8-bit byte.
 * <p>
 * Warning: The <code>read(byte[])</code> and <code>read(byte[], int, int)</code>
 * methods of <code>InputStream</code> will not work appropriately with any
 * bit size &gt; 8 bits. 
 *  
 * @author robgreene@users.sourceforge.net
 */
public class BitInputStream : java.io.InputStream /*implements BitConstants*/ {
  /** Our source of data. */
  private var `is`: java.io.InputStream
  /** The number of bits to read for a request.  This can be adjusted dynamically. */
  private var requestedNumberOfBits : Int = 0
  /** The current bit mask to use when returning a <code>read()</code> request. */
  private var bitMask : Int = 0
  /** The buffer containing our bits.  An int allows 32 bits which should cover up to a 24 bit read if my math is correct.  :-) */
  private var data = 0
  /** Number of bits remaining in our buffer */
  private var bitsOfData = 0
  
  /**
   * Create a BitInputStream wrapping the given <code>InputStream</code>
   * and reading the number of bits specified.
   */
  public init(_ inputStream : java.io.InputStream, _ startingNumberOfBits : Int) {
    self.is = inputStream
    super.init()
    setRequestedNumberOfBits(startingNumberOfBits)
  }
  
  /**
   * Set the number of bits to be read with each call to <code>read()</code>.
   */
  public func setRequestedNumberOfBits(_ numberOfBits : Int) {
    self.requestedNumberOfBits = numberOfBits
    self.bitMask = BitConstants.BIT_MASKS[numberOfBits]
  }
  
  /**
   * Increase the requested number of bits by one.
   * This is the general usage and prevents client from needing to track
   * the requested number of bits or from making various method calls.
   */
  public func increaseRequestedNumberOfBits() {
    setRequestedNumberOfBits(requestedNumberOfBits + 1)
  }
  
  /**
   * Answer with the current bit mask for the current bit size.
   */
  public func getBitMask() -> Int {
    return bitMask
  }
  
  /**
   * Read a number of bits off of the wrapped InputStream.
   */
  public override func read() throws /*IOException*/ -> Int {
    while (bitsOfData < requestedNumberOfBits) {
      var b : Int = try self.is.read()
      if (b == -1) {
        return b
      }
      if (bitsOfData > 0) {
        b <<= bitsOfData	// We're placing b on the high-bit side
      }
      data |= b
      bitsOfData += 8
    }
    let b : Int = data & bitMask
    data >>= requestedNumberOfBits
    bitsOfData -= requestedNumberOfBits
    return b
  }
  
  /**
   * When shifting from buffer to buffer, the input stream also should be reset.
   * This allows the "left over" bits to be cleared.
   */
  public func clearRemainingBitsOfData() {
    self.bitsOfData = 0
    self.data = 0
  }
}
