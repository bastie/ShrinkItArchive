package com.webcodepro.shrinkit;

import java.io.IOException;

import junit.framework.TestCase;

/**
 * Exercise the Master Header Block.
 * For right now, we just grab a "real" header
 * and check it against our computed values.
 * @author robgreene@users.sourceforge.net
 */
public class MasterHeaderBlockTest extends TestCase {
	public void testWithValidCrc() throws IOException {
		ByteSource bs = new ByteSource(new byte[] {
				0x4e, (byte)0xf5, 0x46, (byte)0xe9, 0x6c, (byte)0xe5, (byte)0xdc, 0x1b, 
				0x2d, 0x00, 0x00, 0x00, 0x38, 0x0c, 0x14, 0x5f,
				0x08, 0x07, 0x30, 0x04, 0x29, 0x0d, 0x14, 0x5f,
				0x08, 0x07, 0x01, 0x04, 0x01, 0x00, 0x00, 0x00,
				0x00, 0x00, 0x00, 0x00, 0x00, 0x00, (byte)0xae, (byte)0xac,
				0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			});
		MasterHeaderBlock b = new MasterHeaderBlock(bs);
		// Using byte values since it should be a bit more clear where they came from
		assertEquals(0x1bdc, b.getMasterCrc());
		assertEquals(0x2d, b.getTotalRecords());
		assertEquals(new ByteSource(new byte[] {0x38, 0x0c, 0x14, 0x5f, 0x08, 0x07, 0x30, 0x04}).readDate(), b.getArchiveCreateWhen());
		assertEquals(new ByteSource(new byte[] {0x29, 0x0d, 0x14, 0x5f, 0x08, 0x07, 0x01, 0x04}).readDate(), b.getArchiveModWhen());
		assertEquals(0x01, b.getMasterVersion());
		assertEquals(0x1acae, b.getMasterEof());
		assertTrue(b.isValidCrc());
	}

	public void testWithInvalidCrc() throws IOException {
		ByteSource bs = new ByteSource(new byte[] {
				0x4e, (byte)0xf5, 0x46, (byte)0xe9, 0x6c, (byte)0xe5, 0x00, 0x00,	// <-- Bad CRC! 
				0x2d, 0x00, 0x00, 0x00, 0x38, 0x0c, 0x14, 0x5f,
				0x08, 0x07, 0x30, 0x04, 0x29, 0x0d, 0x14, 0x5f,
				0x08, 0x07, 0x01, 0x04, 0x01, 0x00, 0x00, 0x00,
				0x00, 0x00, 0x00, 0x00, 0x00, 0x00, (byte)0xae, (byte)0xac,
				0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			});
		MasterHeaderBlock b = new MasterHeaderBlock(bs);
		assertFalse(b.isValidCrc());
	}
}
