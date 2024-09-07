import JavApi

/**
 * The RleInputStream handles the NuFX RLE data stream.
 * This data stream is byte oriented.  If a repeat occurs,
 * the data stream will contain the marker byte, byte to 
 * repeat, and the number of repeats (zero based; ie, $00=1,
 * $01=2, ... $ff=256).  The default marker is $DB.
 * 
 * @author robgreene@users.sourceforge.net
 */
public class RleInputStream : java.io.InputStream {
  private var bs : java.io.InputStream
  private var escapeChar : Int
  private var repeatedByte : Int = 0
  private var numBytes : Int = -1
	
	/**
	 * Create an RLE input stream with the default marker byte.
	 */
  public convenience init(_ bs : java.io.InputStream ) {
    self.init(bs, 0xdb);
	}
	/**
	 * Create an RLE input stream with the specified marker byte.
	 */
  public init(_ bs : java.io.InputStream, _ escapeChar : Int) {
		self.bs = bs;
		self.escapeChar = escapeChar;
	}

	/**
	 * Read the next byte from the input stream.
	 */
  public override func read() throws /*IOException*/ -> Int {
		if (numBytes == -1) {
      let b : Int = try bs.read();
			if (b == escapeChar) {
        repeatedByte = try bs.read();
        numBytes = try bs.read();
			} else {
				return b;
			}
		}
		numBytes -= 1
		return repeatedByte;
	}

}
