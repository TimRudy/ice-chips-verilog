// check-index-contents.js
//
// check that the library's index file 'device-index.md' lists every IC device file '*.v'
// found in the directories at or below it, and does not list any non-existent device file
//
// - arguments: none
//
// © 2019-2024 Tim Rudy

import walkSync from 'walk-sync';

import { EOL } from '../common/constants.js';
import { FsReadFileHelper } from '../common/fs-file-helper.js';
import { FsPathHelper } from '../common/fs-path-helper.js';
import { isRegExpMatchStrictMinLength } from '../common/text-helper.js';

const rootOffsetDirectory = '../',
	indexFileName = 'device-index.md';

class IndexFileDeviceFilesService {
	checkIndexedDeviceFiles(indexFileText, deviceFilePathList) {
		// hyperlink expression in the markdown looks like: [{deviceNumber}]({deviceFilePath})
		const indexFileDeviceRefRegExp = new RegExp('\\[([0-9]+[A-Z]{0,1})\\]\\((.*?([0-9]+[A-Z]{0,1})\\.v)\\)', 'i');

		let devicePath, failedMessage;

		const indexFileLines = indexFileText.split(EOL);

		// create lookup map to track devices found on filesystem:
		// - the key is device path + name which looks like: 'source-7400/74xx.v'
		//   (relative to top level directory)
		// - the value is a count in case device is found more than once in index file
		let devicePathMap = {};

		deviceFilePathList.forEach((deviceFilePath) => {
			devicePathMap[deviceFilePath] = 0;
		});

		// go through index file once line by line: record the successful match that should exist
		// in the lookup map by device path + name
		indexFileLines.forEach((indexFileLine) => {
			const subMatches = indexFileDeviceRefRegExp.exec(indexFileLine);

			// while matching the device path + name expression in the line, make sure also the
			// hyperlink text equals the hyperlink ref (without the path and without '.v')
			if (isRegExpMatchStrictMinLength(subMatches, 3)) {
				devicePath = subMatches[2];

				if (devicePathMap[devicePath] >= 0 && subMatches[1] === subMatches[3]) {
					devicePathMap[devicePath]++;
				} else if (subMatches[1] !== subMatches[3]) {
					// malformed hyperlink text
					devicePathMap[devicePath] = -2;
				} else if (devicePathMap[devicePath] === undefined) {
					// not found on filesystem
					devicePathMap[devicePath] = -1;
				}
			}
		});

		// go through the map: ensure one and only one match between filesystem and the lines
		// in the index file
		for (devicePath in devicePathMap) {
			if (devicePathMap[devicePath] === 0) {
				failedMessage = 'Missing listing: ' + devicePath;
			} else if (devicePathMap[devicePath] > 1) {
				failedMessage = 'Duplicate listing: ' + devicePath;
			} else if (devicePathMap[devicePath] === -1) {
				failedMessage = 'Non-existent device listed: ' + devicePath;
			} else if (devicePathMap[devicePath] === -2) {
				failedMessage = 'Malformed listing: ' + devicePath;
			}

			if (failedMessage) {
				console.log('Failed at: ' + failedMessage);
				return 'Failed at: ' + failedMessage;
			}
		}

		console.log('Passed: Index contents');
		return 'Passed: Index contents';
	}
}

const indexFileService = new IndexFileDeviceFilesService();

// main

const fsPath = new FsPathHelper(),
	baseDirectory = fsPath.toAbsolute(rootOffsetDirectory);

const deviceFilePathList = walkSync(baseDirectory, {
	includeBasePath: false,
	globs: [
		'**/*.v'
	],
	ignore: [
		'**/*-tb.v',
		'docs/**',
		'images/**',
		'includes/**',
		'scripts/**'
	]
});

const fsTopLevelIndexInput = new FsReadFileHelper(baseDirectory),
	indexFileText = fsTopLevelIndexInput.readFile(indexFileName);

const testResult = indexFileService.checkIndexedDeviceFiles(
	indexFileText,
	deviceFilePathList
);

if (!testResult.startsWith('Passed')) {
	process.exit(1);
}
