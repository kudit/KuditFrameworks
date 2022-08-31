//
//  Array.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 1/9/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

// we want this usable by Array and Set
public extension Collection {
	/// Returns a shuffled array.
	/// - Returns: a shuffled copy of self
	var shuffled: [Iterator.Element] {
		get {
			var array = Array(self) // copy
			array.shuffle()
			return array
		}
	}
	/// Returns a randomly selected item from the collection.
	@available(*, deprecated, message: "Use native randomElement() method")
	var randomItem: Iterator.Element {
		get {
			return self.randomElement()!
		}
	}
}

/// shuffle is native now

public extension Array where Element: Hashable {
	/// Returns the collection with duplicate values in `self` removed.
	/// Similar to Array(Set(self)) but with order preserved.
	var unique: [Element] {
		get {
			var seen: [Element:Bool] = [:]
			return self.filter { (element) -> Bool in
				return seen.updateValue(true, forKey: element) == nil
			}
		}
	}
	/// Remove all duplicates from the array
	mutating func removeDuplicates() { // better name than "formUnique"
		self = self.unique
	}
}

public extension Array where Element: Comparable {
	/// Append the value only if it doesn't already exist.
	mutating func appendUnique(_ newItem: Element) {
		if !self.contains(newItem) {
			self.append(newItem)
		}
	}
}

public extension Array where Element: Equatable {
	/// like indexOf but with just the element instead of having to construct a predicate.
	@available(*, deprecated, message: "Use new native firstIndex(of:) method")
	func indexOf(item: Element) -> Int? {
		return self.firstIndex(of: item)
	}
	/// remove the object from the array if it exists
	mutating func remove(_ item: Element) {
		while let index = firstIndex(of: item) {
			self.remove(at: index)
		}
	}
}

public extension Collection {
	/// Return the Element at `index` iff the index is in bounds of the array.  Otherwise returns `nil`. Different from normal subscript as normal subscript will just crash with an out of bounds value and will never return nil.  Use like array[safe:5]
	subscript (safe index: Index) -> Iterator.Element? {
		return index >= startIndex && index < endIndex ? self[index] : nil
	}
}