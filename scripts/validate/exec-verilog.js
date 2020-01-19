// exec-verilog.js
//
// - validate every IC device '*.v' by running it through its test bench '*-tb.v'
//
// - argument (optional): top level directory of the project
//
// © 2019 Tim Rudy

const fs = require('fs');
const walkSync = require('walk-sync');
const execSync = require('child_process').execSync;
const fsHelper = require('./fs-helper');

const rootDirectory = '../../';
const sourceDirectory = 'source-7400/';
const includesDirectory = 'includes/';

const osEOLStandard = '\n';

class VerilogTestBenchHelper {
	execAll(fs, deviceFilePathList, includesDirectoryPath) {
		const deviceReferenceRegExp = new RegExp('(.*?([0-9]+))\.v');

		let cumulativeTestCount = 0;
		let deviceTestCount = 0;
		let subMatches, deviceTestOutput, resultMessage;

		try {
			deviceFilePathList.forEach((deviceFilePath) => {
				// pull out the file name without extension, with and without its full path prefix
				subMatches = deviceReferenceRegExp.exec(deviceFilePath);

				if (!subMatches || subMatches.length < 3) {
					throw 'Unexpected file: ' + deviceFilePath;
				} else {
					const testBenchFilePath = subMatches[1] + '-tb.v';
					const deviceNumber = subMatches[2];
					const vvpFileName = subMatches[2] + '-tb.vvp';

					// validate there is a test bench file beside the device file (siblings)
					if (!fs.existsSync(testBenchFilePath)) {
						throw 'No test bench file: ' + testBenchFilePath;
					}

					// collect the logged output from executing iverilog and vvp externally
					deviceTestOutput = this.execDeviceTests(testBenchFilePath,
															deviceFilePath,
															includesDirectoryPath,
															vvpFileName);

					// validate the output; accumulate the tests per device, and total devices
					cumulativeTestCount += this.analyzeTestsPassed(deviceTestOutput,
																	deviceNumber);
					deviceTestCount += 1;
				}
			});

			resultMessage = 'Passed: ' + deviceTestCount + ' devices ' +
							cumulativeTestCount + ' total tests';
		} catch (errorMessage) {
			resultMessage = 'Failed at: ' + errorMessage;
		} finally {
			console.log(resultMessage);
			return resultMessage;
		}
	}

	execDeviceTests(testBenchFilePath, deviceFilePath, includesDirectoryPath, vvpFileName) {
		const iverilogCommand = 'iverilog -g2012' +
								' -o' + vvpFileName +
								' \"' + includesDirectoryPath + 'helper.v' + '\"' +
								' \"' + includesDirectoryPath + 'tbhelper.v' + '\"' +
								' \"' + testBenchFilePath + '\"' +
								' \"' + deviceFilePath + '\"';
		const vvpCommand = 'vvp ' + vvpFileName;

		return execSync(iverilogCommand + ' && ' + vvpCommand, { encoding: 'utf8' }).toString();
	}

	analyzeTestsPassed(results, deviceNumber) {
		const resultsSplitRegExp = new RegExp('[^' + osEOLStandard + ']+', 'g');
		const resultLinePassedRegExp = new RegExp('Passed: (Test.*? (([0-9]+)-)?([0-9]+))[ ]*$', 'm');
		const resultLineExtraVcdReport = 'vcd opened for output';

		let testLineNumber = 0;
		let testLineOuterCount = 0;
		let testLineInnerCount = 0;
		let resultLines, subMatches;

		// split into array of lines
		resultLines = results.match(resultsSplitRegExp);

		resultLines.forEach((resultLine, resultLineIndex) => {
			if (resultLine.length && resultLine.indexOf(resultLineExtraVcdReport) === -1) {
				// parse the standard output line form of 'Passed: ___',
				// which ends with either one index number or two dash-separated numbers,
				// where the first is the inner index and the second is the outer or main index
				subMatches = resultLinePassedRegExp.exec(resultLine);

				// validate that if each line consists of 'Passed: ___' then its test index numbers
				// are strictly incrementing (outer, and then inner if present) - from value '1'
				if (!subMatches || subMatches.length < 3) {
					this.reportUnexpectedLineError(deviceNumber, resultLineIndex, resultLine);
				} else {
					testLineNumber++;

					if (!subMatches[3]) {
						testLineOuterCount++;
						testLineInnerCount = 0;

						if (Number(subMatches[4]) !== testLineOuterCount) {
							this.reportTestNumberSequenceError(deviceNumber,
																resultLineIndex,
																subMatches[1]);
						}
					} else {
						if (!testLineInnerCount || Number(subMatches[4]) === testLineOuterCount + 1) {
							testLineOuterCount++;

							// validate that if inner test index number is starting over, it did not end
							// at only '1' for previous outer index
							if (testLineInnerCount === 1) {
								// report the offending previous line, not current line
								subMatches = resultLinePassedRegExp.exec(resultLines[resultLineIndex - 1]);

								this.reportTestGroupNumberError(deviceNumber,
																resultLineIndex - 1,
																subMatches[1]);
							}

							testLineInnerCount = 1;
						} else {
							testLineInnerCount++;
						}

						if (Number(subMatches[4]) !== testLineOuterCount ||
								Number(subMatches[3]) !== testLineInnerCount) {
							this.reportTestNumberSequenceError(deviceNumber,
																resultLineIndex,
																subMatches[1]);
						}
					}
				}
			}
		});

		return testLineNumber;
	}

	reportTestNumberSequenceError(deviceNumber, outputLineNumber, outputLine) {
		this.reportError('Test number sequence incorrect: ',
							deviceNumber, outputLineNumber, outputLine);
	}

	reportTestGroupNumberError(deviceNumber, outputLineNumber, outputLine) {
		this.reportError('Group consists of only one test (or minor/major index numbers are swapped): ',
							deviceNumber, outputLineNumber, outputLine);
	}

	reportUnexpectedLineError(deviceNumber, outputLineNumber, outputLine) {
		this.reportError('', deviceNumber, outputLineNumber, outputLine);
	}

	reportError(qualifierPrefix, deviceNumber, outputLineNumber, outputLine) {
		throw qualifierPrefix +
				'Device ' + deviceNumber +
				' Output Line ' + outputLineNumber +
				' ' + outputLine;
	}
}

const testBenchHelper = new VerilogTestBenchHelper();

// main

const baseDirectory = fsHelper.getTargetDirectoryOrDefault(
							process.argv.length > 2 && process.argv[2],
							rootDirectory
						);
const deviceDirectoryPath = baseDirectory + sourceDirectory;
const includesDirectoryPath = baseDirectory + includesDirectory;

let deviceFilePathList, testResult;

deviceFilePathList = walkSync(fsHelper.getBasePathFromDirectoryPath(deviceDirectoryPath), {
	includeBasePath: true,
	globs: [
		'**/*.v'
	],
	ignore: [
		'**/*-tb.v'
	]
});

testResult = testBenchHelper.execAll(fs, deviceFilePathList, includesDirectoryPath);

if (!testResult.startsWith('Passed')) {
	process.exit(1);
}
