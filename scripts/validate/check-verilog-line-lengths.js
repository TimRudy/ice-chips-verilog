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

const defaultSourceOffsetDirectory = '../source-7400/';

// main

const fsPath = new FsPathHelper(),
	baseDirectory = fsPath.toAbsolute(
		process.argv.length > 2 && process.argv[2] || defaultSourceOffsetDirectory
	);

const fileLineLengthService = new FileLineLengthService(fsPath);

const filePathList = walkSync(baseDirectory, {
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
