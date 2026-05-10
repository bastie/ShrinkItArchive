/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
import JavApi

/// internal implementation of a specialzied Queue instead of port ConcurrentLinkedQueue in ``LzwInputStream``
internal class ShrinkItArchiveIntQueue : java.util.Queue {
  
  func add(_ element: Int?) throws -> Bool {
    if let element {
      return self.offer(element)
    }
    return false
  }
  
  func addAll(_ collection: any JavApi.java.util.Collection<Int?>) throws -> Bool {
    for element in collection {
      let result = try! self.add(element as! Int)
      if result {
        return false
      }
    }
    return true
  }
  
  func contains(_ element: Int?) -> Bool {
    return self.integers.contains(element ?? -1)
  }
  
  func containsAll(_ collection: any JavApi.java.util.Collection<Int?>) -> Bool {
    for element in collection {
      if !self.contains(element as! ShrinkItArchiveIntQueue.Element) {
        return false
      }
    }
    return true
  }
  
  func remove(_ element: Int?) -> Bool {
    return false
  }
  
  func removeAll(_ collection: any JavApi.java.util.Collection<Int?>) -> Bool {
    return false
  }
  
  func retainAll(_ collection: any JavApi.java.util.Collection<Int?>) -> Bool {
    return false
  }
  
  func toArray() -> [Int?] {
    return self.integers
  }
  
  func toArray(_ array: inout [Int?]) -> [Int?] {
    array = self.integers
    return array
  }
  
  func iterator() -> any JavApi.java.util.Iterator<Int> {
    return MyIterator(integers)
  }
  
  typealias E = Int
  
  func size() -> Int {
    return self.integers.count
  }
  
  typealias IteratorType = MyIterator
  
  func next() -> Int? {
    return self.peek()
  }
  
  typealias Element = Int
  
  private var integers : [Int] = []
  
  
  func add(_ elem: Int) throws -> Bool {
    integers.add(elem)
  }
  
  func element() throws -> Int {
    if let result = peek() {
      return result
    }
    throw java.util.NoSuchElementException()
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
    throw java.util.NoSuchElementException()
  }
  
  func clear() throws {
    self.integers = []
  }
  
  func isEmpty() -> Bool {
    return self.integers.isEmpty
  }
  
  
}

class MyIterator : java.util.Iterator<Int> {
  
  private var index : Int = 0
  private var copy : [Int]
  
  init (_ source : [Int]) {
    copy = [Int](source)
  }
  
  func hasNext() -> Bool {
    return index < copy.count
  }
  
  func next() throws(JavApi.java.util.NoSuchElementException) -> Int {
    if hasNext() {
      let value = copy[index]
      index += 1
      return value
    } else {
      throw JavApi.java.util.NoSuchElementException()
    }
  }
  
  func remove() throws(JavApi.java.lang.IllegalStateException) {
    if index < copy.count {
      _ = copy.remove(at: index)
    }
    else {
      throw JavApi.java.lang.IllegalStateException()
    }
  }
  
  func next() -> Int? {
    if hasNext() {
      let value = copy[index]
      index += 1
      return value
    } else {
      return nil
    }
  }
  
  
}
