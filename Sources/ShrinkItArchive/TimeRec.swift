import JavApi

/**
 * Apple IIgs Toolbox TimeRec object.
 *  
 * @author robgreene@users.sourceforge.net
 */
public class TimeRec {
	private static let SECOND = 0
	private static let MINUTE = 1
	private static let HOUR = 2
	private static let YEAR = 3
	private static let DAY = 4
	private static let MONTH = 5
	private static let WEEKDAY = 7
	private static let LENGTH = 8
  private var data : [UInt8]
	
	/**
	 * Construct a TimeRec with the current date.
	 */
	public convenience init() {
    self.init(java.util.Date());
	}
	/**
	 * Construct a TimeRec with the specified date.  You may pass in a null for a null date (all 0x00's).
	 */
  public init (_ date : java.util.Date) {
    data = [UInt8]()
		setDate(date)
	}
	/**
	 * Construct a TimeRec from the given LENGTH byte array.
	 */
  public init(_ bytes : [UInt8], _ offset : Int) throws {
    if (bytes.length - offset < TimeRec.LENGTH) {
      throw java.lang.Throwable.IllegalArgumentException("TimeRec requires a \(TimeRec.LENGTH) byte array.")
		}
    data =  Array(bytes[offset..<offset+TimeRec.LENGTH])
	}
	/**
	 * Construct a TimeRec from the InputStream.
	 */
  public init(_ inputStream : java.io.InputStream) throws /*IOException*/ {
    data = Array(repeating: 0, count: TimeRec.LENGTH)
    for i in 0..<data.count {
      data[i] = UInt8(try inputStream.read())
		}
	}

	/**
	 * Set the date.
	 */
  public func setDate(_ date : java.util.Date?) {
    data = Array(repeating: 0, count: TimeRec.LENGTH)
		if let date {
      do {
        let gc = java.util.GregorianCalendar()
        gc.setTime(date);
        data[TimeRec.SECOND] = UInt8(try gc.get(java.util.GregorianCalendar.SECOND))
        data[TimeRec.MINUTE] = UInt8(try gc.get(java.util.GregorianCalendar.MINUTE))
        data[TimeRec.HOUR] = UInt8(try gc.get(java.util.GregorianCalendar.HOUR_OF_DAY))
        data[TimeRec.YEAR] = UInt8(Int(try gc.get(java.util.GregorianCalendar.YEAR)) - 1900)
        data[TimeRec.DAY] = UInt8(try gc.get(java.util.GregorianCalendar.DAY_OF_MONTH)) /*- 1*/ /* Bastie Note: I dont no why -1 */
        data[TimeRec.MONTH] = UInt8(try gc.get(java.util.GregorianCalendar.MONTH))
        data[TimeRec.WEEKDAY] = UInt8(try gc.get(java.util.GregorianCalendar.DAY_OF_WEEK))
      }
      catch { //ignored
      }
		}
	}

	/**
	 * Convert the TimeRec into a Java Date object.
	 * Note that years 1900-1939 are assumed to be 2000-2039 per the NuFX addendum.
	 * @see <a href="http://www.nulib.com/library/nufx-addendum.htm">NuFX addendum</a>
	 */
  public func getDate() -> java.util.Date {
    var year : Int = Int(data[TimeRec.YEAR])+1900
    if (year < 1940) {
      year += 100
    }
    let gc = java.util.GregorianCalendar(year, data[TimeRec.MONTH] /*+1*/, data[TimeRec.DAY], data[TimeRec.HOUR], data[TimeRec.MINUTE], data[TimeRec.SECOND])
		return gc.getTime()
	}
	public func getBytes() -> [UInt8]{
		return data
	}
}




