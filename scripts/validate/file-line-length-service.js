// file-line-length-service.js
//
// check that every line in the given list of files is below a max length limit
//
// - stop to report errors on the first file that has bad lines
//
// - inputs:
//   - exceptions to the length limit may be specified through two filter-like functions
//
// © 2020 Tim Rudy

import editorconfig from 'editorconfig';

import { EOL } from '../common/constants.js';
import { FsReadFileHelper } from '../common/fs-file-helper.js';

export class FileLineLengthService {
	constructor(fsPath, fileTypeDisplayName) {
		const tabsRegExp = new RegExp('\t', 'g');

		let tabWidthCache = {};

		// helper to read files: given the reference top level directory, for each read,
		// the relative path + file name will be used
		const fsTopLevelInput = new FsReadFileHelper(fsPath.getReferenceRootDirectory());

		this.checkLimit = (
			filePathList,
			limit,
			ignoreCommonLineFn = null,
			ignoreSpecificLineFn = null
		) => {
			const errorResult = findOneFileLineLengthError(
				filePathList,
				limit,
				ignoreCommonLineFn,
				ignoreSpecificLineFn
			);

			if (!!errorResult.errorFileName) {
				console.log('Failed at: ' + errorResult.errorFileName);

				errorResult.errorLines.forEach((failedLine) => {
					console.log('Line ' + failedLine.lineIndex + ' ' + failedLine.lineText);
				});

				return 'Failed at: ' + errorResult.errorFileName;
			} else {
				const passResultMessage =
					'Passed: Line lengths ' +
					filePathList.length +
					' ' +
					fileTypeDisplayName +
					' files';

				console.log(passResultMessage);
				return passResultMessage;
			}
		};

		// provide the substitute number of characters for tab '\t'
		// - assumption: a flat model of filesystem so there is one .editorconfig value for
		//   each file type being scanned
		//
		function getWorkingProjectTabWidthInfo(filePath) {
			const fileExtension = FsReadFileHelper.getFileExtension(filePath);

			if (tabWidthCache[fileExtension]) {
				return tabWidthCache[fileExtension];
			}

			try {
				const fileConfig = editorconfig.parseSync(filePath);

				const tabWidth = fileConfig.indent_size || fileConfig.tab_width || 2;

				return (tabWidthCache[fileExtension] = {
					tabWidth: tabWidth,
					tabSpaces: ' '.repeat(tabWidth)
				});
			} catch (exception) {
				console.log('Could not read .editorconfig to get tab width:', exception);

				return { tabWidth: 2, tabSpaces: '  ' }; // continue
			}
		}

		function getSubstituteTabSpaceChars(filePath) {
			return getWorkingProjectTabWidthInfo(filePath).tabSpaces;
		}

		function findOneFileLineLengthError(
			filePathList,
			limit,
			ignoreCommonLineFn,
			ignoreSpecificLineFn
		) {
			const displayLimit = limit;

			let errorResult = {
				errorFileName: null,
				errorLines: []
			};

			filePathList.some((filePath) => {
				const shortFilePath = fsPath.toRelativeFromAbsolute({ fullPath: filePath }),
					fileText = fsTopLevelInput.readFile(shortFilePath),
					lines = fileText.split(EOL);

				lines.forEach((line, i) => {
					if (ignoreCommonLineFn && ignoreCommonLineFn(line)) {
						return;
					}

					if (ignoreSpecificLineFn && ignoreSpecificLineFn(shortFilePath, line)) {
						return;
					}

					// account for tabs for complete accuracy
					const tabSpaces = getSubstituteTabSpaceChars(filePath),
						allCharsLine = line.replace(tabsRegExp, tabSpaces);

					// check the length
					if (allCharsLine.length > limit) {
						errorResult.errorLines.push({
							lineIndex: i + 1,
							lineText: allCharsLine.substring(0, displayLimit)
						});
					}
				});

				if (errorResult.errorLines.length) {
					// use the shortened path + file name for reporting
					errorResult.errorFileName = shortFilePath;
					return true;
				} else {
					return false;
				}
			});

			return errorResult;
		}
	}
}
