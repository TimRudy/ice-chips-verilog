// check-verilog-line-lengths.js
//
// check that every Verilog source file has maximum line length of 100
//
// - argument (optional): top level Verilog source code directory
//
// © 2020 Tim Rudy

import walkSync from 'walk-sync';

import { FsPathHelper } from '../common/fs-path-helper.js';
import { FileLineLengthService } from './file-line-length-service.js';

const maxLength = 100;

const defaultSourceDirectory = 'source-7400/';

// main

// set a top level directory for FileLineLengthService to use, and the source code
// directory relative to that
const fsPath = new FsPathHelper(process.argv.length > 2 && process.argv[2]),
	sourceDirectory =
		process.argv.length > 2 && process.argv[2] || fsPath.toAbsolute(defaultSourceDirectory);

const fileLineLengthService = new FileLineLengthService(fsPath);

const filePathList = walkSync(sourceDirectory, {
	includeBasePath: true,
	globs: [
		'**/*.v'
	],
	ignore: [
		'**/helper.v',
		'**/tbhelper.v'
	]
});

const ignoreTbAssert = (fileName, line) => {
	return (
		fileName.lastIndexOf('-tb') !== -1 &&
		line.match(/^\s+(tbassert|case_tbassert)/)
	);
};

const testResult = fileLineLengthService.checkLimit(filePathList, maxLength, null, ignoreTbAssert);

if (!testResult.startsWith('Passed')) {
	process.exit(1);
}
