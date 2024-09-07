/**
 * Provides constants for the LittleEndianByteInputStream and ByteTarget classes.
 * 
 * @author robgreene@users.sourceforge.net
 * @see LittleEndianByteInputStream
 * @see LittleEndianByteOutputStream
 */
public class ByteConstants {
	/** Master Header Block identifier "magic" bytes. */
	public static let NUFILE_ID : [UInt8] = [0x4e, 0xf5, 0x46, 0xe9, 0x6c, 0xe5]
	/** Header Block identifier "magic" bytes. */
	public static let NUFX_ID : [UInt8] = [0x4e, 0xf5, 0x46, 0xd8]
	/** Binary II identifier "magic" bytes. */
	public static let BXY_ID : [UInt8] = [0x0a, 0x47, 0x4c]
	/** Apple IIgs Toolbox TimeRec seconds byte position. */
	public static let TIMEREC_SECOND = 0;
	/** Apple IIgs Toolbox TimeRec seconds byte position. */
	public static let TIMEREC_MINUTE = 1;
	/** Apple IIgs Toolbox TimeRec minutes byte position. */
	public static let TIMEREC_HOUR = 2;
	/** Apple IIgs Toolbox TimeRec hours byte position. */
	public static let TIMEREC_YEAR = 3;
	/** Apple IIgs Toolbox TimeRec year byte position. */
	public static let TIMEREC_DAY = 4;
	/** Apple IIgs Toolbox TimeRec day byte position. */
	public static let TIMEREC_MONTH = 5;
	/** Apple IIgs Toolbox TimeRec weekday (Mon, Tue, etc) byte position. */
	public static let TIMEREC_WEEKDAY = 7;
	/** Apple IIgs Toolbox TimeRec length. */
	public static let TIMEREC_LENGTH = 8;
	/** A null TimeRec */
	public static let TIMEREC_NULL : [UInt8] = Array(repeating: 0, count: TIMEREC_LENGTH)
}
