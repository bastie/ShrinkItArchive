/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
import JavApi

/// internal implementation of a specialzied Queue instead of port ConcurrentLinkedQueue in ``LzwInputStream``
internal class ShrinkItArchiveIntQueue : java.util.Queue {
  private var integers : [Int] = []
  
  
  func add(_ elem: Int) throws -> Bool {
    integers.add(elem)
  }
  
  func element() throws -> Int {
    if let result = peek() {
      return result
    }
    throw java.util.Throwable.NoSuchElementException()
  }
  
  func offer(_ elem: Int) -> Bool {
    do {
      return try self.add(elem)
    }
    catch {
      return false
    }
  }
  
  func peek() -> Int? {
    return isEmpty() ? nil : self.integers[0]
  }
  
  func poll() -> Int? {
    return isEmpty() ? nil : self.integers.remove(at: 0)
  }
  
  func remove() throws -> Int {
    if let result = poll() {
      return result
    }
    throw java.util.Throwable.NoSuchElementException()
  }
  
  typealias Element = Int
  
  func clear() throws {
    self.integers = []
  }
  
  func isEmpty() -> Bool {
    return self.integers.isEmpty
  }
  
  
}

