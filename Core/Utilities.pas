unit Utilities;

interface

uses
  SysUtils, Classes;

{ GUID }
function NewGUID: TGuid;
function NewGUIDStr: String;
function EmptyGUID: TGuid;

{ String }
function JustLetters(AStr: String): String;
function IsNumber(const s: String): Boolean;
function SameString(const S1, S2: String): Boolean;
function StrToUpperWin(Value: String): String;
function NumberToStr(ANumber: Integer): String;
function StrToNumber(AValue: String): Integer;

function IIf(ACondition: Boolean; AResult,AThenResult: String): String;

implementation

function NewGUID: TGuid;
var
  GUID: TGuid;
begin
  CreateGUID(GUID);
  Result:= GUID;
end;

function NewGUIDStr: string;
var
  Guid : TGuid;
begin
  CreateGUID(Guid);
  Result:= GUIDToString(GUID);
end;

function EmptyGUID: TGuid;
begin
  Result:= StringToGUID('{00000000-0000-0000-0000-000000000000}');
end;

function IsNumber(const s: String): Boolean;
var
 i: Integer;
begin
 Result:= True;
 for i := 1 to Length(s) do
   if not (CharInSet(s[i],['0'..'9'])) then Exit(False);
end;

function JustLetters(AStr:string):string;
var
  P: PChar;
begin
  P := PChar(AStr);
  result := '';
  while P^ <> #0 do
  begin
    if CharInSet(P^, ['A'..'Z']) or
       CharInSet(P^, ['a'..'z']) then
    begin
      result := result + char(P^);
    end;
    Inc(P);
  end;
end;

function IIf(ACondition: boolean; AResult,AThenResult: String): String;
begin
  if ACondition then
    Result:= AResult
  else
    Result:= AThenResult;
end;

function SameString(const S1, S2: String): Boolean;
begin
  Result:= SameText(StrToUpperWin(Trim(s1)),(StrToUpperWin(Trim(s2))));
end;

function StrToUpperWin(Value: String): String;
const
  Upperwin: String= '############################### !"#$%&''()*+,-./0123456789:;<='+
    '>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]#_#ABCDEFGHIJKLMNOPQRSTUVWXYZ{'+
    '|}############################################################'+
    '######AAAAAAACEEEEIIIIDNOOOOOXOUUUUY##AAAAAAACEEEEIIII#NOOOOO#OUUUUY';
var
  i: Integer;
  s: String;
begin
  s:= '';
  for i:=1 to Length(Value) do
  begin
    s:= s+UpperWin[Ord(Value[i])];
  end;
  Result:= s;
end;

function NumberToStr(ANumber: Integer): String;
begin
  try
    if ANumber = 0 then
      Result:= ''
    else
      Result:= IntToStr(ANumber)
  except
    Result:= '';
  end;
end;

function StrToNumber(AValue: String): Integer;
begin
  try
    if Trim(AValue) = '' then
      Result:= 0
    else
      Result:= StrToInt(AValue)
  except
    Result:= 0;
  end;
end;

end.
