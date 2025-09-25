// fs-file-helper.js
//
// filesystem utility functions: read and write a file in a given directory
//
// © 2019-2024 Tim Rudy

import fs from 'fs';
import path from 'path';

class FsFileBaseClass {
	static getFileExtension(directoryPathAndOrFileName) {
		return path.extname(directoryPathAndOrFileName);
	}

	constructor(...directories) {
		if (!directories || !directories.length) {
			throw 'Error: Target directory must be specified: ' + JSON.stringify(directories);
		}

		const directory = path.join(...directories);

		if (!path.isAbsolute(directory)) {
			throw 'Error: Target directory must be absolute: ' + directory;
		}

		this.directoryPath = path.resolve(...directories);
	}
}

export class FsReadFileHelper extends FsFileBaseClass {
	constructor(...directories) {
		super(...directories);
	}

	isExistingFile(fileName) {
		return fs.existsSync(path.join(this.directoryPath, fileName));
	}

	readFile(fileName) {
		return fs.readFileSync(path.join(this.directoryPath, fileName), 'utf8');
	}
}

export class FsReadWriteFileHelper extends FsReadFileHelper {
	constructor(...directories) {
		super(...directories);
	}

	writeFile(fileName, fileContent) {
		fs.writeFileSync(path.join(this.directoryPath, fileName), fileContent);
	}
}
