## 0.2.9

- Added documentation of how some parsers work.

## 0.2.8

- Minor changes in `Utf8Reader`.

## 0.2.7

- Minor changes in the JSON parser.

## 0.2.6

- Minor changes to the way UTF8 text is parsed.

## 0.2.5

- Minor changes in the JSON parser.

## 0.2.4

- Fixed bugs.

## 0.2.3

- Fixed bugs.

## 0.2.2

- Added `FileReader` class for buffered reading of data from files.
- Added `Utf8FileReader` class for reading data from text files in UTF8 encoding using the `FileReader` reader.

## 0.2.1

- Fixed bug in `ErrorUnexpectedCharacter` with incorrect behavior with `StringReader`

## 0.2.0

- Breaking change. Now the parser can parse character data from any source, not just directly from a `String`. A lightweight `StringReader` interface has been implemented for this purpose. This practically does not reduce performance and at the same time allows to parse character data directly from files (if there is an implementation of the corresponding string data reader).

## 0.1.11

- Small breaking change. Changed the error handling mechanism to improve performance.

## 0.1.10

- Added error `ErrorExpectedTag`.

## 0.1.9

- Fixed bug in parser `Not`.

## 0.1.8

- Changed the algorithm of the `error handler`, in order to increase performance.
- Added parsers `AllMatches`, `HasMatch`, `Match`, `ReplaceAll`.

## 0.1.7

- Fixed bug in `TakeWhile1` with type argument.

## 0.1.6

- The JSON parser has been moved to `lib\extra\json_parser.dart` and can be used as a dependency.

## 0.1.5

- Added parser `OneOf`.

## 0.1.4

- Added optimizations for the code generator.

## 0.1.3

- Added code generator.

## 0.1.2

- Fixed bugs with class names.
- Added some parser tests.

## 0.1.1

- Fixed bugs with class names.

## 0.1.0

- Public release.