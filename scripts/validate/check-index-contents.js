// check-index-contents.js
//
// - check that the library's index file 'device-index.md' lists every IC device file '*.v'
//   found in directories at or below it (and does not list any non-existent device file)
//
// - argument (optional): top level directory of the project
//
// © 2019 Tim Rudy

const fs = require('fs');
const walkSync = require('walk-sync');
const fsHelper = require('./fs-helper');

const rootDirectory = '../../';
const indexFileName = 'device-index.md';

const osEOLStandard = '\n';

class IndexFileDeviceFilesHelper {
	checkDeviceFilesIndexed(indexFileText, deviceFilePathList) {
		// hyperlink expression in the markdown looks like: [{deviceNumber}]({deviceFilePath})
		const indexFileDeviceRefRegExp =
				new RegExp('\\[([0-9]+[A-Z]{0,1})\\]\\((.*?([0-9]+[A-Z]{0,1})\.v)\\)', 'i');
		const indexFileLines = indexFileText.split(osEOLStandard);

		let devicePathMap = {};
		let subMatches, devicePath, failedMessage;

		// create lookup map to track devices found on filesystem:
		// - the key is device path + name which looks like: 'source-7400/74xx.v'
		//   (relative to top level directory)
		// - the value is a count in case device is found more than once in index file
		deviceFilePathList.forEach((deviceFilePath) => {
			devicePathMap[deviceFilePath] = 0;
		});

		// go through index file once line by line: record the successful match that should exist
		// in the lookup map by device path + name
		indexFileLines.forEach((indexFileLine) => {
			subMatches = indexFileDeviceRefRegExp.exec(indexFileLine);

			// while matching the device path + name expression in the line, make sure also the
			// hyperlink text equals the hyperlink ref (without the path and without '.v')
			if (subMatches) {
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

		// go through the map: ensure one and only one match between filesystem and index file lines
		for (devicePath in devicePathMap) {
			if (devicePathMap[devicePath] === 0) {
				failedMessage = 'Missing listing ' + devicePath;
			} else if (devicePathMap[devicePath] > 1) {
				failedMessage = 'Duplicate listing ' + devicePath;
			} else if (devicePathMap[devicePath] === -1) {
				failedMessage = 'Non-existent device listed ' + devicePath;
			} else if (devicePathMap[devicePath] === -2) {
				failedMessage = 'Malformed listing ' + devicePath;
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

const indexHelper = new IndexFileDeviceFilesHelper();

// main

const baseDirectory = fsHelper.getTargetDirectoryOrDefault(
							process.argv.length > 2 && process.argv[2],
							rootDirectory
						);
const indexFileText = fs.readFileSync(baseDirectory + indexFileName, 'utf8');

let deviceFilePathList, testResult;

deviceFilePathList = walkSync(fsHelper.getBasePathFromDirectoryPath(baseDirectory), {
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

testResult = indexHelper.checkDeviceFilesIndexed(indexFileText, deviceFilePathList);

if (!testResult.startsWith('Passed')) {
	process.exit(1);
}
