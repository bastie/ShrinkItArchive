import JavApi

/**
 * The <code>NufxLzw1InputStream</code> reads a data fork or
 * resource fork written in the NuFX LZW/1 format.
 * <p>
 * The layout of the LZW/1 data is as follows:
 * <table border="0">
 * <tr>
 *   <th colspan="3">"Fork" Header</th>
 * </tr><tr>
 *   <td>+0</td>
 *   <td>Word</td>
 *   <td>CRC-16 of the uncompressed data within the thread</td>
 * </tr><tr>
 *   <td>+2</td>
 *   <td>Byte</td>
 *   <td>Low-level volume number use to format 5.25" disks</td>
 * </tr><tr>
 *   <td>+3</td>
 *   <td>Byte</td>
 *   <td>RLE character used to decode this thread</td>
 * </tr><tr>
 *   <th colspan="3">Each subsequent 4K chunk of data</th>
 * </tr><tr>
 *   <td>+0</td>
 *   <td>Word</td>
 *   <td>Length after RLE compression (if RLE is not used, length 
 *       will be 4096</td>
 * </tr><tr>
 *   <td>+2</td>
 *   <td>Byte</td>
 *   <td>A $01 indicates LZW applied to this chunk; $00 that LZW
 *       <b>was not</b> applied to this chunk</td>
 * </tr>
 * <table>
 * <p>
 * Note that the LZW string table is <em>cleared</em> after
 * every chunk.
 *  
 * @author robgreene@users.sourceforge.net
 */
open class NufxLzw1InputStream : java.io.InputStream {
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
	/** This is the CRC-16 for the uncompressed fork. */
  private var givenCrc : Int = -1
	/** This is the volume number for 5.25" disks. */
  private var volumeNumber : Int = 0
	/** This is the RLE character to use. */
  private var rleCharacter : Int = 0
	/** Used to track the CRC of data we've extracted */
	private var dataCrc = CRC16()
	
	/**
	 * Create the LZW/1 input stream.
	 */
  public init (_ dataStream : LittleEndianByteInputStream) {
		self.dataStream = dataStream
	}

	/**
	 * Read the next byte in the decompressed data stream.
	 */
  open override func read() throws /*IOException*/ -> Int {
		if (givenCrc == -1) {					// read the data or resource fork header
      givenCrc = try dataStream.readWord();
      volumeNumber = try dataStream.readByte();
      rleCharacter = try dataStream.readByte();
			lzwStream = LzwInputStream(BitInputStream(dataStream, 9))
			rleStream = RleInputStream(dataStream, rleCharacter)
      lzwRleStream = RleInputStream(lzwStream!)
		}
		if (bytesLeftInChunk == 0) {		// read the chunk header
			bytesLeftInChunk = 4096		// NuFX always reads 4096 bytes
      lzwStream!.clearDictionary()	// Always clear dictionary
      let length : Int = try dataStream.readWord()
      let lzwFlag : Int = try dataStream.readByte()
      let flag : Int = lzwFlag + (length == 4096 ? 0 : 2);
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
    let b : Int = try decompressionStream!.read()
		bytesLeftInChunk -= 1
		dataCrc.update(b)
		return b
	}
	
	/**
	 * Indicates if the computed CRC matches the CRC given in the data stream.
	 */
	public func isCrcValid() -> Bool {
		return givenCrc == dataCrc.getValue();
	}
	
	// GENERATED CODE

	public func getGivenCrc() -> Int {
		return givenCrc;
	}
  public func setGivenCrc(_ givenCrc : Int) {
		self.givenCrc = givenCrc;
	}
	public func getVolumeNumber() -> Int{
		return volumeNumber;
	}
  public func setVolumeNumber(_ volumeNumber : Int) {
		self.volumeNumber = volumeNumber;
	}
	public func getRleCharacter() -> Int {
		return rleCharacter;
	}
  public func setRleCharacter(_ rleCharacter: Int) {
		self.rleCharacter = rleCharacter;
	}
	public func getDataCrc() -> Int64{
		return dataCrc.getValue();
	}
}
