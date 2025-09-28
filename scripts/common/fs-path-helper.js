// fs-path-helper.js
//
// utility functions: resolve path strings used for filesystem
//
// - note: convention: a "path" is in absolute form unless otherwise indicated
//
// - functionality is:
//   - maintain a reference top level path that is an effective root in the filesystem;
//     supports relative paths
//   - create a full directory + file path from path segments
//   - provide a full directory path in case a given path is relative
//   - provide a relative path referenced from a level of a full directory path
//
// © 2019-2024 Tim Rudy

import path from 'path';
import url from 'url';

export class FsPathHelper {
	// create normalized, absolute, path string from segments
	//
	static resolve(...directoriesAndOrFile) {
		return path.resolve(...directoriesAndOrFile);
	}

	constructor(specifiedRootDirectory) {
		if (specifiedRootDirectory && !path.isAbsolute(specifiedRootDirectory)) {
			throw (
				'Error: Root directory, if specified, must be absolute: ' +
				specifiedRootDirectory
			);
		}

		this.referenceRootDirectory = specifiedRootDirectory || getProjectRootDirectoryPath();

		// get path string of the project root directory, as fixed reference for the running script
		//
		function getProjectRootDirectoryPath() {
			const thisFilePath = url.fileURLToPath(import.meta.url),
				thisDirectory = path.dirname(thisFilePath),
				rootOffsetDirectory = '../../'; // from this Node.js file

			return path.resolve(thisDirectory, rootOffsetDirectory);
		}
	}

	getReferenceRootDirectory() {
		return this.referenceRootDirectory;
	}

	// accept an absolute or relative directory path, and if relative, attach it to
	// this path helper's root directory
	//
	toAbsolute(targetDirectory) {
		if (typeof targetDirectory !== 'string') {
			throw (
				'Error: Directory must be a string: ' +
				JSON.stringify(targetDirectory)
			);
		}

		if (path.isAbsolute(targetDirectory)) {
			return targetDirectory;
		} else {
			return FsPathHelper.resolve(this.referenceRootDirectory, targetDirectory);
		}
	}

	// provide a shorter, relative-path version of a path + file name
	// by removing the common path prefix of either this path helper's root directory
	// (default) or the directory specified
	//
	toRelativeFromAbsolute({ specifiedRootDirectory, fullPath }) {
		if (specifiedRootDirectory && !path.isAbsolute(specifiedRootDirectory)) {
			throw (
				'Error: Directory giving the common root, if specified, must be absolute: ' +
				specifiedRootDirectory
			);
		}

		if (!fullPath) {
			throw 'Error: Directory path + file name must be specified';
		}

		const shortPathAndOrFileName = path.relative(
			specifiedRootDirectory || this.referenceRootDirectory,
			fullPath
		);

		if (
			!shortPathAndOrFileName ||
			path.isAbsolute(shortPathAndOrFileName) ||
			shortPathAndOrFileName.startsWith('.')
		) {
			throw (
				'====> Assertion failed (' +
				'Directory path + file name does not exist on the common root: ' +
				fullPath +
				')'
			);
		}

		return shortPathAndOrFileName;
	}
}
