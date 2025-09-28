// fs-directory-helper.js
//
// filesystem utility functions: access a given directory, read or write
//
// © 2019-2024 Tim Rudy

import fs from 'fs';

export class FsReadDirectoryHelper {
	// access directory on the filesystem
	//
	static confirmDirectoryExists(directory) {
		if (!fs.existsSync(directory)) {
			throw 'Error: No directory: ' + directory;
		} else {
			const stats = fs.lstatSync(directory);

			if (!stats.isDirectory()) {
				throw 'Error: Not a directory: ' + directory;
			}
		}

		return true;
	}
}

export class FsWriteDirectoryHelper {
	// access directory on the filesystem and if it doesn't exist, create it
	//
	static confirmDirectoryExists(directory) {
		if (!fs.existsSync(directory)) {
			fs.mkdirSync(directory, { recursive: true });
		} else {
			const stats = fs.lstatSync(directory);

			if (!stats.isDirectory()) {
				throw 'Error: Exists but not a directory: ' + directory;
			}
		}

		return true;
	}
}
