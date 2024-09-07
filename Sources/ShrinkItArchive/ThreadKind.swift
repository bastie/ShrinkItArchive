import JavApi

/**
 * Define and decode the thread_kind field.
 * @author robgreene@users.sourceforge.net
 */
public enum ThreadKind {
  case ASCII_TEXT
  case ALLOCATED_SPACE
  case APPLE_IIGS_ICON
  case CREATE_DIRECTORY
  case DATA_FORK
  case DISK_IMAGE
  case RESOURCE_FORK
  case FILENAME
  
  /**
   * Find the specific ThreadKind.
   * @throws IllegalArgumentException when the thread_kind cannot be determined
   */
  public static func find (_ threadKind : Int, _ threadClass : ThreadClass) throws -> ThreadKind {
    switch (threadClass) {
    case ThreadClass.MESSAGE:
      switch (threadKind) {
      case 0x0000: return ASCII_TEXT
      case 0x0001: return ALLOCATED_SPACE
      case 0x0002: return APPLE_IIGS_ICON
      default : break
      }
      throw Throwable.IllegalArgumentException("Unknown thread_kind \(threadKind) for message thread_class of \(threadClass)")
    case ThreadClass.CONTROL:
      if (threadKind == 0x0000) {
        return CREATE_DIRECTORY
      }
      throw Throwable.IllegalArgumentException("Unknown thread_kind \(threadKind) for control thread_class of \(threadClass)")
    case ThreadClass.DATA:
      switch (threadKind) {
      case 0x0000: return DATA_FORK
      case 0x0001: return DISK_IMAGE
      case 0x0002: return RESOURCE_FORK
      default: break
      }
      throw Throwable.IllegalArgumentException("Unknown thread_kind \(threadKind) for data thread_class of \(threadClass)")
    case ThreadClass.FILENAME:
      if (threadKind == 0x0000) {
        return FILENAME
      }
      throw Throwable.IllegalArgumentException("Unknown thread_kind \(threadKind) for filename thread_class of \(threadClass)")
    }
  }
}
