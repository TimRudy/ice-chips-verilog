// text-helper.js
//
// utility functions for text strings
//
// © 2020-2023 Tim Rudy

export function isRegExpMatchExpectedLength(subMatches, expectedLength) {
	return (
		subMatches &&
		subMatches.length === expectedLength &&
		subMatches[expectedLength - 1] !== undefined
	);
}

export function isRegExpMatchMinLength(subMatches, minLength) {
	return (
		subMatches &&
		subMatches.length >= minLength
	);
}

export function isRegExpMatchStrictMinLength(subMatches, minLength) {
	return (
		subMatches &&
		subMatches.length >= minLength &&
		subMatches[minLength - 1] !== undefined
	);
}
