import JavApi

/**
 * The <code>NufxLzw2InputStream</code> reads a data fork or
 * resource fork written in the NuFX LZW/2 format.
 * <p>
 * The layout of the LZW/2 data is as follows:
 * <table border="0">
 * <tr>
 *   <th colspan="3">"Fork" Header</th>
 * </tr><tr>
 *   <td>+0</td>
 *   <td>Byte</td>
 *   <td>Low-level volume number used to format 5.25" disks</td>
 * </tr><tr>
 *   <td>+1</td>
 *   <td>Byte</td>
 *   <td>RLE character used to decode this thread</td>
 * </tr><tr>
 *   <th colspan="3">Each subsequent 4K chunk of data</th>
 * </tr><tr>
 *   <td>+0</td>
 *   <td>Word</td>
 *   <td>Bits 0-12: Length after RLE compression<br/>
 *       Bit 15: LZW flag (set to 1 if LZW used)</td>
 * </tr><tr>
 *   <td>+2</td>
 *   <td>Word</td>
 *   <td>If LZW flag = 1, total bytes in chunk<br/>
 *       Else (flag = 0) start of data</td>
 * </tr>
 * <table>
 * <p>
 * The LZW/2 dictionary is only cleared when the table becomes full and is indicated
 * in the input stream by 0x100.  It is also cleared whenever a chunk that is not
 * LZW encoded is encountered.
 *  
 * @author robgreene@users.sourceforge.net
 */
public class NufxLzw2InputStream : java.io.InputStream {
	/** This is the raw data stream with all markers and compressed data. */
	private var dataStream : LittleEndianByteInputStream
	/** Used for an LZW-only <code>InputStream</code>. */
	private var lzwStream : LzwInputStream?
	/** Used for an RLE-only <code>InputStream</code>. */
	private var rleStream : RleInputStream?
	/** Used for an LZW+RLE <code>InputStream</code>. */
	private var lzwRleStream : java.io.InputStream?
	/** This is the generic decompression stream from which we read. */
  private var decompressionStream : java.io.InputStream?
	/** Counts the number of bytes in the 4096 byte chunk. */
  private var bytesLeftInChunk : Int = 0
	/** This is the volume number for 5.25" disks. */
  private var volumeNumber : Int = -1
	/** This is the RLE character to use. */
  private var rleCharacter : Int = 0
	/** Used to track the CRC of data we've extracted */
	private var dataCrc = CRC16();
	
	/**
	 * Create the LZW/2 input stream.
	 */
  public init(_ dataStream : LittleEndianByteInputStream) {
		self.dataStream = dataStream;
	}

	/**
	 * Read the next byte in the decompressed data stream.
	 */
  public override func read() throws /*IOException*/ -> Int {
		if (volumeNumber == -1) {				// read the data or resource fork header
      volumeNumber = try dataStream.readByte();
      rleCharacter = try dataStream.readByte();
			lzwStream = LzwInputStream(BitInputStream(dataStream, 9));
			rleStream = RleInputStream(dataStream, rleCharacter);
      lzwRleStream = RleInputStream(lzwStream!);
		}
		if (bytesLeftInChunk == 0) {		// read the chunk header
			bytesLeftInChunk = 4096;		// NuFX always reads 4096 bytes
      lzwStream!.clearData();			// Allow the LZW stream to do a little housekeeping
      let word : Int = try dataStream.readWord();
      let length : Int = word & 0x7fff;
      let lzwFlag : Int = word & 0x8000;
			if (lzwFlag == 0) {				// We clear dictionary whenever a non-LZW chunk is encountered
        lzwStream!.clearDictionary();
			} else {
        _ = try dataStream.readWord();		// At this time, I just throw away the total bytes in this chunk...
			}
      let flag : Int = (lzwFlag == 0 ? 0 : 1) + (length == 4096 ? 0 : 2);
			switch (flag) {
			case 0:		decompressionStream = dataStream;
						break;
      case 1:		decompressionStream = lzwStream!;
						break;
      case 2:		decompressionStream = rleStream!;
						break;
      case 3:		decompressionStream = lzwRleStream!;
						break;
      default:	throw java.io.Throwable.IOException("Unknown type of decompression, flag = \(flag)")
			}
		}
		// Now we can read a data byte
    let b : Int = try decompressionStream!.read();
		bytesLeftInChunk -= 1
		dataCrc.update(b)
		return b
	}
	
	// GENERATED CODE

	public func getVolumeNumber() -> Int {
		return volumeNumber;
	}
  public func setVolumeNumber(_ volumeNumber : Int) {
		self.volumeNumber = volumeNumber;
	}
	public func  getRleCharacter() -> Int {
		return rleCharacter;
	}
  public func setRleCharacter(_ rleCharacter : Int) {
		self.rleCharacter = rleCharacter;
	}
	public func getDataCrc() -> Int64{
		return dataCrc.getValue();
	}
}
