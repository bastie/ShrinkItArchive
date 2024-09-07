import JavApi
import Foundation

import ShrinkItArchive

/**
 * Scan through the directories in NufxScan.txt, looking for 
 * *.SHK and *.SDK files.  When one is found, do a file listing
 * (including compression types) and dump to screen.
 * <p>
 * Adding some minor hard-coded searching capabilities.
 * 
 * @author robgreene@users.sourceforge.net
 */
@main
public class NufxScan {
	
  public static func main () throws /*IOException*/ {
    var args = ProcessInfo.processInfo.arguments
    args.remove(at: 0)
    if (args.length == 0) {
      print ("Scan NuFX/Shrinkit archives.  Please include at least one path name.")
    } else {
      if (args.length == 1 && "-v".equals(args[0])) {
        print ("ShrinkIt Library version \(NuFileArchive.VERSION)")
      } else {
        for dir in args {
          try scanDirectory(dir);
        }
      }
    }
  }
	
  private static func scanDirectory(_ dirName : String) throws /*IOException*/ {
    let dir = java.io.File(dirName)
    try scanDirectory(dir)
	}
	
  private static func scanDirectory(_ directory : java.io.File) throws /*IOException*/ {

    var archiveWithSmallestCompressedFile : java.io.File?
    var smallestCompressedFilename : String?
    var sizeOfSmallestCompressedFile : Int64 = 0

    print ("Scanning '\(directory.toString())'...\n")
		if (!directory.isDirectory()) {
      throw Throwable.IllegalArgumentException("'\(directory.toString())' is not a directory")
		}
    var files : [java.io.File] = directory.listFiles(NufxScan.NuFxFileFilter())!
		for file in files {
			if (file.isDirectory()) {
				try scanDirectory(file);
			} else {
        try displayArchive(file, sizeOfSmallestCompressedFile: &sizeOfSmallestCompressedFile, archiveWithSmallestCompressedFile: &archiveWithSmallestCompressedFile, smallestCompressedFilename: &smallestCompressedFilename);
			}
		}
		if (sizeOfSmallestCompressedFile != 0) {
			print ("\n\nSmallest compressed file:")
      print ("Archive = \(archiveWithSmallestCompressedFile!.getAbsoluteFile())")
			print ("Filename = \(smallestCompressedFilename!)")
      let hexSizeOfSmallestCompressedFile = String (format: "%08x", sizeOfSmallestCompressedFile)
			print ("Size = \(hexSizeOfSmallestCompressedFile) (\(sizeOfSmallestCompressedFile))")
		}
	}
	
  private static func displayArchive(_ archive : java.io.File, sizeOfSmallestCompressedFile : inout Int64,  archiveWithSmallestCompressedFile : inout java.io.File?, smallestCompressedFilename : inout String?) throws /*IOException*/ {
    print("Details for \(archive.getAbsoluteFile())\n")
    // ---
    let data = try Data (contentsOf: URL(fileURLWithPath: archive.getAbsolutePath()))
    let inputStream : java.io.InputStream = java.io.ByteArrayInputStream(array: data)
    // ---
    //let inputStream : java.io.InputStream = java.io.FileInputStream(archive)
		do {
      let a : NuFileArchive = try NuFileArchive(inputStream)
			print("Ver# Threads  FSId FSIn Access   FileType ExtraTyp Stor Thread Formats..... OrigSize CompSize Filename");
			print("==== ======== ==== ==== ======== ======== ======== ==== =================== ======== ======== ==============================");
      for b : HeaderBlock in a.getHeaderBlocks() {
        let hexVersionNumber = String (format: "%04x", b.getVersionNumber())
        let hexTotalThreads = String (format: "%08x", b.getTotalThreads())
        let hexFileSysId = String (format: "%04x", b.getFileSysId())
        let hexFileSysInfo = String (format: "%04x", b.getFileSysInfo())
        let hexAccess = String (format: "%08x", b.getAccess())
        let hexFileType = String (format: "%08x", b.getFileType())
        let hexExtraType = String (format: "%08x", b.getExtraType())
        let hexStorageType = String (format: "%04x", b.getStorageType())
        print("\(hexVersionNumber) \(hexTotalThreads) \(hexFileSysId) \(hexFileSysInfo) \(hexAccess) \(hexFileType) \(hexExtraType) \(hexStorageType) ", terminator : "")
				var threadsPrinted = 0
				var filename = b.getFilename()
        var origSize : Int64 = 0;
        var compSize : Int64 = 0;
				var compressed = false;
				for r : ThreadRecord in b.getThreadRecords() {
					threadsPrinted += 1
          let hexVersionNumber = String (format: "%04x", r.getThreadFormat().getThreadFormat)
          print("\(hexVersionNumber) ", terminator : "")
          compressed = compressed || (r.getThreadFormat() != ThreadFormat.UNCOMPRESSED())
					if (r.getThreadKind() == ThreadKind.FILENAME) {
            filename = r.getText()!
					}
					if (r.getThreadClass() == ThreadClass.DATA) {
						origSize += r.getThreadEof()
						compSize += r.getCompThreadEof()
					}
				}
				while threadsPrinted < 4 {
          print("     ", terminator: "")
					threadsPrinted += 1
				}
        let hexOrigSize = String (format: "%08x", origSize)
        let hexCompSize = String (format: "%08x", compSize)
				System.out.print("\(hexOrigSize) \(hexCompSize) ");
				if (filename.count == 0) {
					filename = "<Unknown>"
				}
				print (filename)
        if (compressed && (sizeOfSmallestCompressedFile == 0 || compSize < sizeOfSmallestCompressedFile)) {
					sizeOfSmallestCompressedFile = compSize
					archiveWithSmallestCompressedFile = archive
					smallestCompressedFilename = filename
				}
			}
			print()
		}
	}
}
