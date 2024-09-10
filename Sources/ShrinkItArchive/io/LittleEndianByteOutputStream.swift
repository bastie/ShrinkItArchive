import JavApi

/**
 * An OutputStream with helper methods to write little endian numbers
 * and other Apple-specific tidbits.
 * 
 * @author robgreene@users.sourceforge.net
 */
public class LittleEndianByteOutputStream : java.io.OutputStream /*implements ByteConstants*/ {
  private var outputStream : java.io.OutputStream
  private var bytesWritten : Int64 = 0
  private var crc = CRC16()
  
  /**
   * Construct a LittleEndianByteOutputStream from an OutputStream.
   */
  public init(_ outputStream : java.io.OutputStream) {
    self.outputStream = outputStream;
  }
  
  /**
   * Write a next byte.
   */
  public override func write(_ b: Int) throws /*IOException*/ {
    try outputStream.write(b)
    crc.update(b)
  }
  
  /**
   * Write the NuFile id to the LittleEndianByteOutputStream.
   */
  public func writeNuFileId() throws /*IOException*/ {
    try write(ByteConstants.NUFILE_ID)
  }
  /**
   * Write the NuFX id to the LittleEndianByteOutputStream.
   */
  public func writeNuFxId() throws /*IOException*/ {
    try write(ByteConstants.NUFX_ID)
  }
  /**
   * Write a "Word".
   */
  public func writeWord(_ w : Int) throws /*IOException*/ {
    try write(w & 0xff);
    try write(w >> 8);
  }
  /**
   * Write a "Long".
   */
  public func writeLong(_ l : Int64) throws /*IOException*/ {
    try write(Int(l & 0xff));
    try write(Int((l >> 8) & 0xff));
    try write(Int((l >> 16) & 0xff));
    try write(Int((l >> 24) & 0xff));
  }
  /**
   * Write the Java Date object as a TimeRec.
   * Note that years 2000-2039 are assumed to be 00-39 per the NuFX addendum.
   * @see <a href="http://www.nulib.com/library/nufx-addendum.htm">NuFX addendum</a>
   */
  public func writeDate(_ date : java.util.Date?) throws /*IOException*/ {
    
    if let date {
      var data : [UInt8] = Array(repeating: 0, count: ByteConstants.TIMEREC_LENGTH)
      let gc = java.util.GregorianCalendar()
      gc.setTime(date);
      var year : Int = try gc.get(java.util.GregorianCalendar.YEAR);
      year -= (year < 2000) ? 1900 : 2000;
      data[ByteConstants.TIMEREC_YEAR] = UInt8(year & 0xff)
      data[ByteConstants.TIMEREC_MONTH] = UInt8(try gc.get(java.util.GregorianCalendar.MONTH))/* + 1);*/ /* Basties note: why*/
      data[ByteConstants.TIMEREC_DAY] = UInt8(try gc.get(java.util.GregorianCalendar.DAY_OF_MONTH))
      data[ByteConstants.TIMEREC_HOUR] = UInt8(try gc.get(java.util.GregorianCalendar.HOUR_OF_DAY))
      data[ByteConstants.TIMEREC_MINUTE] = UInt8(try gc.get(java.util.GregorianCalendar.MINUTE))
      data[ByteConstants.TIMEREC_SECOND] = UInt8(try gc.get(java.util.GregorianCalendar.SECOND))
      data[ByteConstants.TIMEREC_WEEKDAY] = UInt8(try gc.get(java.util.GregorianCalendar.DAY_OF_WEEK))
      try write(data);
    }
    else {
      let data = ByteConstants.TIMEREC_NULL;
      try write(data);
    }
  }
  
  /**
   * Reset the CRC-16 to $0000.
   */
  public func resetCrc() {
    crc.reset()
  }
  /**
   * Get the current CRC-16 value.
   */
  public func getCrcValue() -> Int64{
    return crc.getValue();
  }
  
  /**
   * Answer with the total number of bytes written.
   */
  public func getTotalBytesWritten() -> Int64{
    return bytesWritten;
  }
  
  /**
   * Pass the flush request to the wrapped stream.
   */
  public override func flush() throws /*IOException*/ {
    try outputStream.flush();
  }
  /**
   * Pass the close request to the wrapped stream.
   */
  public override func close() throws /*IOException*/ {
    try outputStream.close();
  }
}
