import '../parser/choice.dart';
import '../parser/delimited.dart';
import '../parser/eof.dart';
import '../parser/fast.dart';
import '../parser/malformed.dart';
import '../parser/many.dart';
import '../parser/map.dart';
import '../parser/not.dart';
import '../parser/opt.dart';
import '../parser/satisfy.dart';
import '../parser/separated_list1.dart';
import '../parser/skip_while.dart';
import '../parser/tag.dart';
import '../parser/tags.dart';
import '../parser/take_while.dart';
import '../parser/terminated.dart';
import '../parser/value.dart';

const parser = Terminated(name: 'parser', _rows, _eof);

const _chars = Many(Choice2(
  Satisfy(isNotQuote),
  ValueP(0x22, Tag('""')),
));

const _closeQuote = Fast2(name: '_closeQuote', _quote, _ws);

const _eof = Eof(name: '_eof');

const _eol = Tags(name: '_eol', ['\n', '\r\n', '\r']);

const _field = Choice2(name: '_field', _string, _text);

const _openQuote = Fast2(name: '_openQuote', _ws, _quote);

const _quote = Tag(name: '_quote', '"');

const _row = SeparatedList1(name: '_row', _field, Tag(','));

const _rowEnding = Fast2(name: '_rowEnding', _eol, Not(_eof));

const _rows =
    Terminated(name: '_rows', SeparatedList1(_row, _rowEnding), Opt(_eol));

const _string = Malformed(
    Map1(Delimited(_openQuote, _chars, _closeQuote), String.fromCharCodes),
    'Unterminated string');

const _text = TakeWhile(name: '_text', isTextChar);

const _ws = SkipWhile(name: '_ws', isWhitespace);

bool isNotQuote(int c) => c != 0x22;

bool isTextChar(int c) => !(c == 0xa || c == 0xd || c == 0x2c);

bool isWhitespace(int c) => c == 0x9 || c == 0x20;
