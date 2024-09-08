import JavApi

/**
 * The RleOutputStream handles the NuFX RLE data stream.
 * This data stream is byte oriented.  If a repeat occurs,
 * the data stream will contain the marker byte, byte to 
 * repeat, and the number of repeats (zero based; ie, $00=1,
 * $01=2, ... $ff=256).  The default marker is $DB.
 * 
 * @author robgreene@users.sourceforge.net
 */
public class RleOutputStream : java.io.OutputStream {
  private var os : java.io.OutputStream
  private var escapeChar : Int
  private var repeatedByte : Int
  private var numBytes : Int = -1;
	
	/**
	 * Create an RLE output stream with the default marker byte.
	 */
  public convenience init(_ bs : java.io.OutputStream) {
    self.init (bs, Int(0xdb))
	}
	/**
	 * Create an RLE output stream with the specified marker byte.
	 */
  public init(_ os : java.io.OutputStream , _ escapeChar : Int) {
		self.os = os
		self.escapeChar = escapeChar
	}
	
	/**
	 * Write the next byte to the output stream.
	 */
  public override func write(_ b : Int) throws /*IOException*/ {
		if (numBytes == -1) {
			repeatedByte = b
			numBytes += 1
		} else if (repeatedByte == b) {
			numBytes += 1
			if (numBytes > 255) {
        try flush()
			}
		} else {
      try flush()
			repeatedByte = b
			numBytes += 1
		}
	}
	
	/**
	 * Flush out any remaining data.
	 * If we only have 1 byte and it is <em>not</em> the repeated
	 * byte, we can just dump that byte.  Otherwise, we need to
	 * write out the escape character, the repeated byte, and
	 * the number of bytes. 
	 */
  public override func flush() throws /*IOException*/ {
		if (numBytes != -1) {
			if (numBytes == 0 && escapeChar != repeatedByte) {
        try os.write(repeatedByte);
			} else {
        try os.write(escapeChar);
        try os.write(repeatedByte);
        try os.write(numBytes);
			}
			numBytes = -1;
		}
	}
	
	/**
	 * Close out the data stream.  Makes sure the repeat buffer
	 * is flushed.
	 */
  public override func close() throws /*IOException*/ {
    try flush()
    try os.close()
	}
}
