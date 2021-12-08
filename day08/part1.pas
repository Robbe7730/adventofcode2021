program Part1;

uses crt, strutils, types;

var l: String;
var l_split: TStringDynArray;
var outputs_split: TStringDynArray;
var output_text: String;
var res: Integer;

begin
    res := 0;
    while not eof() do
    begin
        readln(l);
        l_split := SplitString(l, '|');
        outputs_split := SplitString(l_split[1], ' ');
        for output_text in outputs_split do
        begin
            if (Length(output_text) = 2) or (Length(output_text) = 3) or (Length(output_text) = 4) or (Length(output_text) = 7) then
                res := res + 1
            ;
        end;
    end;
    writeln(res);
end.
