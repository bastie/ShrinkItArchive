import JavApi

/**
 * The Master Header Block contains information about the entire
 * ShrinkIt archive.
 * <p>
 * Note that we need to support multiple versions of the NuFX
 * archive format.  Some details may be invalid, depending on
 * version, and those are documented in the getter methods.
 *  
 * @author robgreene@users.sourceforge.net
 * @see <a href="http://www.nulib.com/library/FTN.e08002.htm">Apple II File Type Note $E0/$8002</a>
 */
public class MasterHeaderBlock {
	private static let MASTER_HEADER_LENGTH = 48
	private var masterCrc : Int
	private var validCrc : Bool
	private var totalRecords : Int64
	private var archiveCreateWhen : java.util.Date?
	private var archiveModWhen : java.util.Date?
	private var masterVersion : Int
	private var masterEof : Int64

	/**
	 * Create the Master Header Block, based on the LittleEndianByteInputStream.
	 */
	public init (_ bs : LittleEndianByteInputStream) throws /*IOException*/ {
		var fileType = 0
    var headerOffset = 0
    fileType = try bs.seekFileType()
		if (fileType == NuFileArchive.BXY_ARCHIVE) {
      _ = try bs.readBytes(127 - ByteConstants.NUFILE_ID.count)
			headerOffset = 128
      let count : Int = try bs.read()
			if (count != 0) {
				throw java.io.Throwable.IOException("This is actually a Binary II archive with multiple files in it."); // FIXME - NLS
			}
      fileType = try bs.seekFileType()
		}
		if (!(fileType == NuFileArchive.NUFILE_ARCHIVE)) {
			throw java.io.Throwable.IOException("Unable to decode this archive.") // FIXME - NLS
		}
    masterCrc = try bs.readWord()
		bs.resetCrc()	// CRC is computed from this point to the end of the header
    totalRecords = try bs.readLong()
    archiveCreateWhen = try bs.readDate()
    archiveModWhen = try bs.readDate()
    masterVersion = try bs.readWord()
		if (masterVersion > 0) {
      _ = try bs.readBytes(8)		// documented to be null, but we don't care
      masterEof = try bs.readLong()
		} 
    else {
			masterEof = -1
		}
		// Read whatever remains of the fixed size header
    while (bs.getTotalBytesRead() < MasterHeaderBlock.MASTER_HEADER_LENGTH + headerOffset) {
      _ = try bs.readByte()
		}
		validCrc = (masterCrc == bs.getCrcValue())
	}
	
	// GENERATED CODE

	public func getMasterCrc() -> Int {
		return masterCrc;
	}
	public func setMasterCrc(_ masterCrc : Int) {
		self.masterCrc = masterCrc;
	}
	public func getTotalRecords() -> Int64 {
		return totalRecords;
	}
	public func setTotalRecords(_ totalRecords : Int64) {
		self.totalRecords = totalRecords;
	}
	public func getArchiveCreateWhen() -> java.util.Date? {
		return archiveCreateWhen;
	}
	public func setArchiveCreateWhen(_ archiveCreateWhen : java.util.Date) {
		self.archiveCreateWhen = archiveCreateWhen;
	}
	public func getArchiveModWhen() -> java.util.Date? {
		return archiveModWhen;
	}
	public func setArchiveModWhen(_ archiveModWhen : java.util.Date) {
		self.archiveModWhen = archiveModWhen;
	}
	public func getMasterVersion() -> Int {
		return masterVersion;
	}
	public func setMasterVersion(_ masterVersion : Int) {
		self.masterVersion = masterVersion;
	}
	public func getMasterEof() -> Int64 {
		return masterEof;
	}
	public func setMasterEof(_ masterEof : Int64) {
		self.masterEof = masterEof;
	}
	public func isValidCrc() -> Bool{
		return validCrc;
	}
}
