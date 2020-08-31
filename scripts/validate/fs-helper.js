// fs-helper.js
//
// - filesystem path utility functions
//
// © 2019 Tim Rudy

class FsHelper {
	getTargetDirectoryOrDefault(userArgDirectory, defaultDirectory) {
		let targetDirectory;

		if (userArgDirectory) {
			targetDirectory = userArgDirectory;

			// if the input is not of absolute or relative form (relative to the current working
			// directory), then is relative to defaultDirectory
			if (!(targetDirectory.startsWith('.') ||
					targetDirectory.startsWith('/') || targetDirectory.startsWith('\\') ||
					targetDirectory.indexOf(':/') === 1 || targetDirectory.indexOf(':\\') === 1)) {
				targetDirectory = defaultDirectory + targetDirectory;
			}

			// put in canonical form of a directory (it will act as a prefix)
			if (!(targetDirectory.endsWith('/') || targetDirectory.endsWith('\\'))) {
				targetDirectory = targetDirectory + '/';
			}
		} else {
			targetDirectory = defaultDirectory;
		}

		return targetDirectory;
	}

	getBasePathFromDirectoryPath(directory) {
		// remove slash at the end (no longer the canonical form of a directory)
		return directory.substr(0, directory.length - 1);
	}
}

module.exports = new FsHelper();
