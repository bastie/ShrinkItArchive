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
	public func write(_ b: Int) throws /*IOException*/ {
		outputStream.write(b)
		crc.update(b)
	}

	/**
	 * Write the NuFile id to the LittleEndianByteOutputStream.
	 */
	public func writeNuFileId() throws /*IOException*/ {
		write(NUFILE_ID)
	}
	/**
	 * Write the NuFX id to the LittleEndianByteOutputStream.
	 */
	public func writeNuFxId() throws /*IOException*/ {
		write(NUFX_ID)
	}
	/**
	 * Write a "Word".
	 */
	public func writeWord(_ w : Int) throws /*IOException*/ {
		write(w & 0xff);
		write(w >> 8);
	}
	/**
	 * Write a "Long".
	 */
	public func writeLong(_ l : Int64) throws /*IOException*/ {
		write((int)(l & 0xff));
		write((int)((l >> 8) & 0xff));
		write((int)((l >> 16) & 0xff));
		write((int)((l >> 24) & 0xff));
	}
	/**
	 * Write the Java Date object as a TimeRec.
	 * Note that years 2000-2039 are assumed to be 00-39 per the NuFX addendum.
	 * @see <a href="http://www.nulib.com/library/nufx-addendum.htm">NuFX addendum</a>
	 */
	public func writeDate(_ date : java.util.Date) throws /*IOException*/ {
		byte[] data = null;
		if (date == null) {
			data = TIMEREC_NULL;
		} else {
			data = new byte[TIMEREC_LENGTH];
			GregorianCalendar gc = new GregorianCalendar();
			gc.setTime(date);
			int year = gc.get(Calendar.YEAR);
			year -= (year < 2000) ? 1900 : 2000;
			data[TIMEREC_YEAR] = (byte)(year & 0xff);
			data[TIMEREC_MONTH] = (byte)(gc.get(Calendar.MONTH))/* + 1);*/ /* Basties note: why*/
			data[TIMEREC_DAY] = (byte)gc.get(Calendar.DAY_OF_MONTH);
			data[TIMEREC_HOUR] = (byte)gc.get(Calendar.HOUR_OF_DAY);
			data[TIMEREC_MINUTE] = (byte)gc.get(Calendar.MINUTE);
			data[TIMEREC_SECOND] = (byte)gc.get(Calendar.SECOND);
			data[TIMEREC_WEEKDAY] = (byte)gc.get(Calendar.DAY_OF_WEEK);
		}
		write(data);
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
	public func flush() throws /*IOException*/ {
		outputStream.flush();
	}
	/**
	 * Pass the close request to the wrapped stream.
	 */
	public func close() throws /*IOException*/ {
		outputStream.close();
	}
}
