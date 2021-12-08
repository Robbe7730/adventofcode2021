program Part2;

uses crt, strutils, types, fgl;

type TMapSI = specialize TFPGMap<String, Integer>;
type TMapSS = specialize TFPGMap<String, String>;

var l: String;
var l_split: TStringDynArray;
var outputs_split: TStringDynArray;
var output_text: String;
var inputs_split: TStringDynArray;
var input_text: String;
var res: Int64;
var occurences: TMapSI;
var one_input: String;
var four_input: String;
var seven_input: String;
var mapping: TMapSS;
var curr_char: Char;
var fixed_output_text: String;
var digits: TMapSI;
var number: Integer;

const all_letters: String = 'abcdefg';

begin
    digits := TMapSI.Create;

    digits['abcefg'] := 0;
    digits['cf'] := 1;
    digits['acdeg'] := 2;
    digits['acdfg'] := 3;
    digits['bcdf'] := 4;
    digits['abdfg'] := 5;
    digits['abdefg'] := 6;
    digits['acf'] := 7;
    digits['abcdefg'] := 8;
    digits['abcdfg'] := 9;

    one_input := '';
    four_input := '';
    seven_input := '';
    res := 0;
    while not eof() do
    begin
        occurences := TMapSI.Create;
        mapping := TMapSS.Create;
        readln(l);
        l_split := SplitString(l, '|');
        inputs_split := SplitString(l_split[0], ' ');
        outputs_split := SplitString(l_split[1], ' ');
        for input_text in inputs_split do
        begin
            for curr_char in input_text do
            begin
                if(occurences.IndexOf(curr_char) < 0) then
                begin
                    occurences[curr_char] := 0;
                end;
                occurences[curr_char] := occurences[curr_char] + 1;
            end;

            if Length(input_text) = 2 then
                one_input := input_text
            else if Length(input_text) = 3 then
                seven_input := input_text
            else if Length(input_text) = 4 then
                four_input := input_text;
        end;

        mapping['e'] := occurences.Keys[occurences.IndexOfData(4)];
        mapping['b'] := occurences.Keys[occurences.IndexOfData(6)];
        mapping['f'] := occurences.Keys[occurences.IndexOfData(9)];

        for curr_char in one_input do
        begin
            if (mapping.IndexOfData(curr_char) < 0) then
            begin
                mapping['c'] := curr_char;
            end;
        end;

        for curr_char in seven_input do
        begin
            if (mapping.IndexOfData(curr_char) < 0) then
            begin
                mapping['a'] := curr_char;
            end;
        end;

        for curr_char in four_input do
        begin
            if (mapping.IndexOfData(curr_char) < 0) then
            begin
                mapping['d'] := curr_char;
            end;
        end;

        for curr_char in all_letters do
        begin
            if (mapping.IndexOfData(curr_char) < 0) then
            begin
                mapping['g'] := curr_char;
            end;
        end;

        number := 0;
        for output_text in outputs_split do
        begin
            if Length(output_text) > 0 then
            begin
                fixed_output_text := '';
                for curr_char in all_letters do
                begin
                    if (Pos(mapping[curr_char], output_text) > 0) then
                        fixed_output_text := fixed_output_text + curr_char;
                end;
                number := number*10 + digits[fixed_output_text]
            end;
        end;
        res += number;
    end;
    writeln(res);
end.
