import JavApi

/**
 * Define and decode the thread_class field.
 * @author robgreene@users.sourceforge.net
 */
public enum ThreadClass {
	case MESSAGE
  case CONTROL
  case DATA
  case FILENAME

	/**
	 * Find the given ThreadClass.
	 * @throws IllegalArgumentException if the thread_class is unknown
	 */
  public static func find(_ threadClass : Int) throws -> ThreadClass {
		switch (threadClass) {
		case 0x0000: return MESSAGE
		case 0x0001: return CONTROL
		case 0x0002: return DATA
		case 0x0003: return FILENAME
		default:
      throw Throwable.IllegalArgumentException("Unknown thread_class of \(threadClass)")
		}
	}
}
