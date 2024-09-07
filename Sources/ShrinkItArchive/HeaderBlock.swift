import JavApi

/**
 * The Header Block contains information and content
 * about a single entry (be it a file or disk image).
 * <p>
 * Note that we need to support multiple versions of the NuFX
 * archive format.  Some details may be invalid, depending on
 * version, and those are documented in the getter methods.
 * 
 * @author robgreene@users.sourceforge.net
 * @see <a href="http://www.nulib.com/library/FTN.e08002.htm">Apple II File Type Note $E0/$8002</a>
 */
open class HeaderBlock {
  private var headerCrc : Int
  private var attribCount : Int
  private var versionNumber : Int
  private var totalThreads : Int64
  private var fileSysId : Int
  private var fileSysInfo : Int
  private var access : Int64
  private var fileType : Int64
  private var extraType : Int64
  private var storageType : Int
  private var createWhen : java.util.Date?
  private var modWhen : java.util.Date?
  private var archiveWhen : java.util.Date?
  private var optionSize : Int = 0
  private var optionListBytes : [UInt8]?
  private var attribBytes : [UInt8]?
  private var filename : String?
  private var rawFilename : String?
  private var headerSize : Int64 = 0
  private var threads : [ThreadRecord] = [ThreadRecord]();
	
	/**
	 * Create the Header Block.  This is done dynamically since
	 * the Header Block size varies significantly.
	 */
  public init (_ bs : LittleEndianByteInputStream) throws /*IOException*/ {
    let type : Int = try bs.seekFileType(4);
		if (type == 0) {
      throw java.io.Throwable.IOException("Unable to decode this archive.");  // FIXME - NLS
		}
    headerCrc = try bs.readWord();
    attribCount = try bs.readWord();
    versionNumber = try bs.readWord();
		totalThreads = try bs.readLong();
		fileSysId = try bs.readWord();
		fileSysInfo = try bs.readWord();
		access = try bs.readLong();
		fileType = try bs.readLong();
		extraType = try bs.readLong();
		storageType = try bs.readWord();
		createWhen = try bs.readDate();
		modWhen = try bs.readDate();
		archiveWhen = try bs.readDate();
		// Read the mysterious option_list
		if (versionNumber >= 1) {
			optionSize = try bs.readWord();
			if (optionSize > 0) {
				optionListBytes = try bs.readBytes(optionSize-2);
			}
		}
		// Compute attribute bytes that exist and read (if needed)
    var sizeofAttrib : Int = attribCount - 58;
		if (versionNumber >= 1) {
      if (optionSize == 0) {
        sizeofAttrib -= 2
      }
      else {
        sizeofAttrib -= optionSize
      }
		}
		if (sizeofAttrib > 0) {
			attribBytes = try bs.readBytes(sizeofAttrib);
		}
		// Read the (defunct) filename
    let length : Int = try bs.readWord();
		if (length > 0) {
			rawFilename = String(try bs.readBytes(length));
		}
		if (rawFilename == nil) {
			rawFilename = "Unknown";
		}
	}
	/**
	 * Read in all data threads.  All ThreadRecords are read and then
	 * each thread's data is read (per NuFX spec).
	 */
  public func readThreads(_ bs : LittleEndianByteInputStream) throws /*IOException*/ {
    for _ : Int64 in 0..<totalThreads {
      _ = threads.add (try ThreadRecord(self, bs))
    }
    for r : ThreadRecord in threads {
      try r.readThreadData(bs)
			headerSize += r.getThreadEof()
		}
	}

	/**
	 * Locate the filename and return it.  It may have been given in the old
	 * location, in which case, it is in the String filename.  Otherwise it will
	 * be in the filename thread.  If it is in the thread, we shove it in the 
	 * filename variable just so we don't need to search for it later.  This 
	 * should not be a problem, because if we write the file, we'll write the
	 * more current version anyway.
	 */
	public func getFilename() -> String {
		if (filename == nil) {
      let r : ThreadRecord? = findThreadRecord(ThreadKind.FILENAME)
      if let r  {
        filename = r.getText()
      }
      if (filename == nil) {
        filename = rawFilename
      }
			if (filename!.contains(":")) {
				filename = filename!.replace(":","/")
			}
		}
		return filename!
	}
	
	/**
	 * Final element in the path, in those cases where a filename actually holds a path name
	 */
	public func getFinalFilename() -> String {
    var filename : String = getFilename();
    var path : [String]
		path = filename.split("/");
		filename = path[path.length - 1];
		return filename;
	}
	
	/**
	 * Get the data fork.
	 * Note that this first searches the data fork and then searches for a disk image; 
	 * this may not be correct behavior.
	 */
	public func getDataForkThreadRecord() -> ThreadRecord {
    var thread : ThreadRecord? = findThreadRecord(ThreadKind.DATA_FORK)
		if (thread == nil) {
			thread = findThreadRecord(ThreadKind.DISK_IMAGE)
		}
		return thread!
	}

	/**
	 * Get the resource fork.
	 */
	public func getResourceForkThreadRecord() -> ThreadRecord {
		return findThreadRecord(ThreadKind.RESOURCE_FORK)!
	}

	/**
	 * Locate a ThreadRecord by it's ThreadKind.
	 */
  public func findThreadRecord(_ tk : ThreadKind) -> ThreadRecord? {
    for r : ThreadRecord in threads {
      if (r.getThreadKind() == tk) {
        return r
      }
		}
		return nil
	}
	
	// HELPER METHODS
	
	/**
	 * Helper method to determine the file system separator.
	 * Due to some oddities, breaking apart by byte value...
	 */
	public func getFileSystemSeparator() -> String {
		switch (getFileSysInfo() & 0xff) {
		case 0xaf: fallthrough
		case 0x2f:
			return "/";
		case 0x3a: fallthrough
		case 0xba: fallthrough
		case 0x3f:	// Note that $3F is per the documentation(!)
			return ":";
		case 0x5c: fallthrough
		case 0xdc:
			return "\\";
		default:
			return "";
		}
	}
	
	public func getUncompressedSize() -> Int64 {
    var size : Int64 = 0
		for r : ThreadRecord in threads {
			if (r.getThreadClass() == ThreadClass.DATA) {
				size += r.getThreadEof();
			}
		}
		return size;
	}
	public func getCompressedSize() -> Int64 {
    var size : Int64 = 0;
		for r : ThreadRecord in threads {
			if (r.getThreadClass() == ThreadClass.DATA) {
				size += r.getCompThreadEof();
			}
		}
		return size;
	}

	// GENERATED CODE
	
	public func getHeaderCrc() -> Int {
		return headerCrc;
	}
  public func setHeaderCrc(_ headerCrc : Int) {
		self.headerCrc = headerCrc;
	}
	public func getAttribCount() -> Int {
		return attribCount;
	}
  public func setAttribCount(_ attribCount : Int) {
		self.attribCount = attribCount;
	}
	public func getVersionNumber() -> Int {
		return versionNumber;
	}
  public func setVersionNumber(_ versionNumber : Int) {
		self.versionNumber = versionNumber;
	}
	public func getTotalThreads() -> Int64 {
		return totalThreads;
	}
  public func setTotalThreads(_ totalThreads : Int64) {
		self.totalThreads = totalThreads;
	}
	public func getFileSysId() -> Int {
		return fileSysId;
	}
  public func setFileSysId(_ fileSysId : Int) {
		self.fileSysId = fileSysId;
	}
	public func getFileSysInfo() -> Int {
		return fileSysInfo;
	}
  public func setFileSysInfo(_ fileSysInfo : Int) {
		self.fileSysInfo = fileSysInfo;
	}
	public func getAccess() -> Int64 {
		return access;
	}
  public func setAccess(_ access : Int64) {
		self.access = access;
	}
	public func getFileType() -> Int64{
		return fileType;
	}
  public func setFileType(_ fileType : Int64) {
		self.fileType = fileType;
	}
	public func getExtraType() -> Int64 {
		return extraType;
	}
  public func setExtraType(_ extraType : Int64) {
		self.extraType = extraType;
	}
	public func getStorageType() -> Int {
		return storageType;
	}
  public func setStorageType(_ storageType : Int) {
		self.storageType = storageType;
	}
  public func getCreateWhen() -> java.util.Date? {
		return createWhen;
	}
  public func setCreateWhen(_ createWhen : java.util.Date) {
		self.createWhen = createWhen;
	}
  public func getModWhen() -> java.util.Date? {
		return modWhen;
	}
  public func setModWhen(_ modWhen : java.util.Date) {
		self.modWhen = modWhen;
	}
  public func getArchiveWhen() -> java.util.Date? {
		return archiveWhen;
	}
  public func setArchiveWhen(_ archiveWhen : java.util.Date) {
		self.archiveWhen = archiveWhen;
	}
	public func getOptionSize() -> Int {
		return optionSize;
	}
  public func setOptionSize(_ optionSize : Int) {
		self.optionSize = optionSize;
	}
	public func getOptionListBytes() -> [UInt8]? {
		return optionListBytes;
	}
  public func setOptionListBytes(_ optionListBytes : [UInt8]) {
		self.optionListBytes = optionListBytes;
	}
	public func getAttribBytes() -> [UInt8]? {
		return attribBytes;
	}
  public func setAttribBytes(_ attribBytes : [UInt8]) {
		self.attribBytes = attribBytes;
	}
  public func setFilename(_ filename : String) {
		self.filename = filename;
	}
	public func getRawFilename() -> String? {
		return rawFilename;
	}
	public func getThreadRecords() -> [ThreadRecord] {
		return threads;
	}
  public func setThreadRecords(_ threads : [ThreadRecord]) {
		self.threads = threads;
	}
	public func getHeaderSize() -> Int64 {
		return headerSize;
	}
}
