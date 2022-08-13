//
//  File.swift
//  
//
//  Created by Ben Ku on 8/12/22.
//

import Foundation

extension FileManager {
	enum FileError: Error {
		case noDirectorySpecified
	}
	/**
	This will move a file from the source to the destination overwriting an existing file if there is one.  By default it creates any missing directories necessary.
	*/
	
	func files(in directory: URL) throws -> [URL] {
		let files = try contentsOfDirectory(at: directory, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)
		
		//let sortedFiles = files.sorted()
		
		return files
	}
}

