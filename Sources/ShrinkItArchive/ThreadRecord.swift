import JavApi
import Foundation

/**
 * This represents a single thread from the Shrinkit archive.
 * As it is constructed, the thread "header" is read.  Once all
 * threads have been constructed, use <code>readThreadData</code>
 * to load up the data.
 * <p>
 * Depending on the type of thread, the data may be text.  If so,
 * <code>isText</code> will return true and <code>getText</code>
 * will return the string. Otherwise the data should be read through
 * one of the <code>InputStream</code> options.
 * 
 * @author robgreene@users.sourceforge.net
 */
public class ThreadRecord {
  private var threadClass : ThreadClass
  private var threadFormat : ThreadFormat
  private var threadKind : ThreadKind
  private var threadCrc : Int
  private var threadEof : Int64
  private var compThreadEof : Int64
  private var threadData : [UInt8]?

	/**
	 * Construct the ThreadRecord and read the header details with no hints
	 * from the Header Block.
	 */
  public convenience init (_ bs : LittleEndianByteInputStream) throws /*IOException*/ {
    try self.init(nil, bs);
	}

	/**
	 * Construct the ThreadRecord and read the header details.
	 */
  public init(_ hb : HeaderBlock?, _ bs : LittleEndianByteInputStream) throws /*IOException*/ {
    threadClass = try ThreadClass.find(try bs.readWord());
    threadFormat = try ThreadFormat.find(bs.readWord());
    threadKind = try ThreadKind.find(bs.readWord(), threadClass);
    threadCrc = try bs.readWord();
    threadEof = try bs.readLong();
    compThreadEof = try bs.readLong();
    if let hb {
      if (threadKind == ThreadKind.DISK_IMAGE) {
        /* If we have hints from the header block, repair some disk image related bugs. */
        if (hb.getStorageType() <= 13 ) {
          /* supposed to be block size, but SHK v3.0.1 stored it wrong */
          threadEof = hb.getExtraType() * 512;
          // System.out.println("Found erroneous storage type... fixing.");
        } else if (hb.getStorageType() == 256 &&
                   hb.getExtraType() == 280 &&
                   hb.getFileSysId() == 2 ) { // FileSysDOS33
          /*
           * Fix for less-common ShrinkIt problem: looks like an old
           * version of GS/ShrinkIt used 256 as the block size when
           * compressing DOS 3.3 images from 5.25" disks.  If that
           * appears to be the case here, crank up the block size.
           */
          threadEof = hb.getExtraType() * 512;
        } else {
          threadEof = hb.getExtraType() * Int64(hb.getStorageType());
        }
      }
    }
	}

	/**
	 * Read the raw thread data.  This must be called.
	 */
  public func readThreadData(_ bs : LittleEndianByteInputStream) throws /*IOException*/ {
    threadData = try bs.readBytes(Int(compThreadEof))
	}
	/**
	 * Determine if this is a text-type field.
	 */
	public func isText() -> Bool {
		return threadKind == ThreadKind.ASCII_TEXT || threadKind == ThreadKind.FILENAME
	}
	/**
	 * Return the text data.
	 */
	public func getText() -> String? {
    return isText() ? String (data:  Data(Array(threadData![0..<Int(threadEof)])), encoding: .utf8)  : nil
	}
	/**
	 * Get raw data bytes (compressed).
	 */
	public func getBytes() -> [UInt8]? {
		return threadData
	}
	/**
	 * Get the raw data input stream.
	 */
  public func getRawInputStream() -> java.io.InputStream {
    return java.io.ByteArrayInputStream (threadData!)
	}
	/**
	 * Get the appropriate input data stream for this thread to decompress the contents.
	 */
  public func getInputStream() throws /*IOException*/ -> java.io.InputStream {
		switch (threadFormat) {
    case ThreadFormat.UNCOMPRESSED:
			return getRawInputStream()
    case ThreadFormat.DYNAMIC_LZW1:
			return NufxLzw1InputStream(LittleEndianByteInputStream(getRawInputStream()))
    case ThreadFormat.DYNAMIC_LZW2:
			return NufxLzw2InputStream(LittleEndianByteInputStream(getRawInputStream()))
		default:
      throw java.io.Throwable.IOException("The thread format \(threadFormat) does not have an InputStream associated with it!")
		}
	}
	
	// GENERATED CODE
	
	public func getThreadClass() -> ThreadClass {
		return threadClass
	}
  public func setThreadClass(_ threadClass : ThreadClass) {
		self.threadClass = threadClass
	}
	public func getThreadFormat() -> ThreadFormat {
		return threadFormat
	}
  public func setThreadFormat(_ threadFormat : ThreadFormat) {
		self.threadFormat = threadFormat
	}
	public func getThreadKind() -> ThreadKind {
		return threadKind
	}
  public func setThreadKind(_ threadKind : ThreadKind) {
		self.threadKind = threadKind
	}
	public func getThreadCrc() -> Int {
		return threadCrc
	}
  public func setThreadCrc(_ threadCrc : Int) {
		self.threadCrc = threadCrc
	}
	public func getThreadEof() -> Int64 {
		return threadEof
	}
  public func setThreadEof(_ threadEof : Int64) {
		self.threadEof = threadEof
	}
	public func getCompThreadEof() -> Int64 {
		return compThreadEof
	}
  public func setCompThreadEof(_ compThreadEof : Int64) {
		self.compThreadEof = compThreadEof
	}
	public func getThreadData() -> [UInt8]? {
		return threadData
	}
  public func setThreadData(_ threadData : [UInt8]) {
		self.threadData = threadData
	}
}
