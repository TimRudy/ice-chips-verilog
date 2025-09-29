// exec-verilog.js
//
// validate every IC device '*.v': run it through its test bench '*-tb.v', and
// enforce that there is a test bench for every device
//
// - argument (optional): "-s" suppress dump file output and give only success/fail
//
// © 2019-2024 Tim Rudy

import { execSync } from 'child_process';
import walkSync from 'walk-sync';

import { EOL, EOL_MATCH_REG_EXP } from '../common/constants.js';
import { FsWriteDirectoryHelper } from '../common/fs-directory-helper.js';
import { FsReadFileHelper } from '../common/fs-file-helper.js';
import { FsPathHelper } from '../common/fs-path-helper.js';
import { isRegExpMatchMinLength } from '../common/text-helper.js';

const sourceSubDirectory = 'source-7400/',
	includesSubDirectory = 'includes/',
	workingSubDirectory = 'scripts/validate/',
	outputSubDirectory = 'output/';

class TestBenchService {
	constructor(isSuppressDumpFile) {
		this.execAll = (
			devicesDirectory,
			deviceFilePathList,
			includesSubDirectory,
			outputDirectory
		) => {
			const deviceRefRegExp = new RegExp('(.*?([0-9]+))\\.v');

			const fsDevicesInput = new FsReadFileHelper(devicesDirectory);

			let resultMessage;

			let cumulativeTestCount = 0,
				deviceTestCount = 0;

			try {
				deviceFilePathList.forEach((deviceFilePath) => {
					// pull out the file name without extension, with and without its
					// full path prefix
					const subMatches = deviceRefRegExp.exec(deviceFilePath);

					if (!isRegExpMatchMinLength(subMatches, 3)) {
						throw 'Unexpected file: ' + deviceFilePath;
					} else {
						const testBenchPathAndFileName = subMatches[1] + '-tb.v',
							testBenchFileName = subMatches[2] + '-tb.v',
							deviceNumber = subMatches[2],
							vvpFileName = subMatches[2] + '-tb.vvp',
							vvpPathAndFileName = FsPathHelper.resolve(
								outputDirectory,
								vvpFileName
							);

						// validate there is a test bench file beside the device file (siblings)
						if (!fsDevicesInput.isExistingFile(testBenchFileName)) {
							throw 'No test bench file: ' + testBenchFileName;
						}

						// collect the logged output from executing command line iverilog and vvp
						const deviceTestOutput = execDeviceTests(
							testBenchPathAndFileName,
							deviceFilePath,
							includesSubDirectory,
							vvpPathAndFileName
						);

						// validate the output; accumulate the tests per-device, and for the total
						cumulativeTestCount += analyzeTestsPassed(deviceTestOutput, deviceNumber);
						deviceTestCount += 1;
					}
				});

				resultMessage =
					'Passed: ' +
					deviceTestCount +
					' devices ' +
					cumulativeTestCount +
					' total tests';
			} catch (errorMessage) {
				resultMessage = 'Failed at: ' + errorMessage;
			} finally {
				console.log(resultMessage);
				return resultMessage;
			}
		};

		function execDeviceTests(
			testBenchPathAndFileName,
			deviceFilePath,
			includesSubDirectory,
			vvpPathAndFileName
		) {
			const iverilogCommand =
				'iverilog -g2012' +
				' -o' + vvpPathAndFileName +
				' "' + FsPathHelper.resolve(includesSubDirectory, 'helper.v') + '"' +
				' "' + FsPathHelper.resolve(includesSubDirectory, 'tbhelper.v') + '"' +
				' "' + testBenchPathAndFileName + '"' +
				' "' + deviceFilePath + '"';

			const vvpCommand = 'vvp ' + vvpPathAndFileName + (isSuppressDumpFile ? ' -none' : '');

			return execSync(iverilogCommand + ' && ' + vvpCommand, {
				encoding: 'utf8'
			}).toString();
		}

		function analyzeTestsPassed(results, deviceNumber) {
			const resultsSplitRegExp = new RegExp('[^' + EOL + ']+', 'g'),
				resultLinePassedRegExp = new RegExp('Passed: (Test.*? (([0-9]+)-)?([0-9]+))[ ]*$', 'm'),
				resultExtraStartRegExp = new RegExp('(.*opened for output\\.)|(.*dumping is suppressed\\.)$', 'm'),
				resultExtraFinishRegExp = new RegExp('.+\\$finish called.+');

			let subMatches;

			let testLineNumber = 0,
				testLineOuterCount = 0,
				testLineInnerCount = 0;

			// split into array of lines
			const resultLines = results.match(resultsSplitRegExp),
				resultLinesLastIndex = resultLines.length - 1;

			resultLines.forEach((resultLine, resultLineIndex) => {
				if (
					resultLine.length &&
					!(
						(resultLineIndex === 0 &&
							!!resultExtraStartRegExp.exec(resultLine)) ||
						(resultLineIndex === resultLinesLastIndex &&
							!!resultExtraFinishRegExp.exec(resultLine))
					)
				) {
					// parse the standard output line form of 'Passed: ___',
					// which ends with either one index number or two dash-separated numbers,
					// where the first is the inner index and the second is the outer or main index
					subMatches = resultLinePassedRegExp.exec(resultLine);

					// validate that if each line consists of 'Passed: ___' then its test
					// index numbers are strictly incrementing (outer, and then inner if present),
					// from value '1'
					if (!isRegExpMatchMinLength(subMatches, 3)) {
						reportUnexpectedLineError(
							deviceNumber,
							resultLineIndex,
							resultLine
						);
					} else {
						testLineNumber++;

						if (!subMatches[3]) {
							testLineOuterCount++;
							testLineInnerCount = 0;

							if (Number(subMatches[4]) !== testLineOuterCount) {
								reportTestNumberSequenceError(
									deviceNumber,
									resultLineIndex,
									subMatches[1]
								);
							}
						} else {
							if (
								!testLineInnerCount ||
								Number(subMatches[4]) === testLineOuterCount + 1
							) {
								testLineOuterCount++;

								// validate that if inner test index number is starting over,
								// it did not end at only '1' for previous outer index
								if (testLineInnerCount === 1) {
									// report the offending previous line, not current line
									subMatches = resultLinePassedRegExp.exec(
										resultLines[resultLineIndex - 1]
									);

									reportTestGroupNumberError(
										deviceNumber,
										resultLineIndex - 1,
										subMatches[1]
									);
								}

								testLineInnerCount = 1;
							} else {
								testLineInnerCount++;
							}

							if (
								Number(subMatches[4]) !== testLineOuterCount ||
								Number(subMatches[3]) !== testLineInnerCount
							) {
								reportTestNumberSequenceError(
									deviceNumber,
									resultLineIndex,
									subMatches[1]
								);
							}
						}
					}
				}
			});

			return testLineNumber;
		}

		function reportTestNumberSequenceError(deviceNumber, outputLineNumber, outputLine) {
			reportError(
				'Test number sequence incorrect: ',
				deviceNumber,
				outputLineNumber,
				outputLine
			);
		}

		function reportTestGroupNumberError(deviceNumber, outputLineNumber, outputLine) {
			reportError(
				'Group consists of only one test (or minor/major index numbers are swapped): ',
				deviceNumber,
				outputLineNumber,
				outputLine
			);
		}

		function reportUnexpectedLineError(deviceNumber, outputLineNumber, outputLine) {
			reportError(
				'',
				deviceNumber,
				outputLineNumber,
				outputLine
			);
		}

		function reportError(qualifierPrefix, deviceNumber, outputLineNumber, outputLine) {
			throw (
				qualifierPrefix +
				'Device ' +
				deviceNumber +
				' Output Line ' +
				outputLineNumber +
				': ' +
				outputLine
			);
		}
	}
}

const testBenchService = new TestBenchService(
	process.argv.length > 2 && process.argv[2] === '-s'
);

// main

const fsPath = new FsPathHelper(),
	baseDirectory = fsPath.getReferenceRootDirectory(),
	workingDirectory = fsPath.toAbsolute(workingSubDirectory);

const devicesDirectory = FsPathHelper.resolve(baseDirectory, sourceSubDirectory),
	includesDirectory = FsPathHelper.resolve(baseDirectory, includesSubDirectory),
	outputDirectory = FsPathHelper.resolve(workingDirectory, outputSubDirectory);

FsWriteDirectoryHelper.confirmDirectoryExists(outputDirectory);

const deviceFilePathList = walkSync(devicesDirectory, {
	includeBasePath: true,
	globs: [
		'**/*.v'
	],
	ignore: [
		'**/*-tb.v'
	]
});

const testResult = testBenchService.execAll(
	devicesDirectory,
	deviceFilePathList,
	includesDirectory,
	outputDirectory
);

if (!testResult.startsWith('Passed')) {
	process.exit(1);
}
