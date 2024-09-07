import JavApi
import Foundation

/**
 * Basic reading of a NuFX archive.
 * 
 * @author robgreene@users.sourceforge.net
 */
open class NuFileArchive {
  public static let VERSION = "\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.2.2")"
  
  private var master : MasterHeaderBlock
  private var headers : [HeaderBlock]
  private var totalSize : Int64 = 0;
  
  /**
   * Need to enumerate some basic sub-types of archives.
   */
  public static let NUFILE_ARCHIVE = 1;
  public static let NUFX_ARCHIVE = 2;
  public static let BXY_ARCHIVE = 3;
  
  /**
   * Read in the NuFile/NuFX/Shrinkit archive.
   */
  public init(_ inputStream : java.io.InputStream) throws /*IOException*/ {
    let bs : LittleEndianByteInputStream = LittleEndianByteInputStream(inputStream)
    master = try MasterHeaderBlock (bs);
    headers = [HeaderBlock]();
    for _ in 0..<master.getTotalRecords() {
      let header : HeaderBlock = try HeaderBlock(bs);
      try header.readThreads(bs);
      _ = headers.add(header);
      totalSize += header.getHeaderSize();
    }
  }
  
  /**
   * @return long size in bytes of the archive
   */
  public func getArchiveSize() -> Int64 {
    return totalSize;
  }
  
  public func getMasterHeaderBlock() -> MasterHeaderBlock {
    return master;
  }
  public func getHeaderBlocks() -> [HeaderBlock] {
    return headers;
  }
}
