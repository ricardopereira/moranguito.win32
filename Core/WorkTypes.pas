unit WorkTypes;

interface

uses
  SysUtils, Classes, TypInfo, Variants;

const
  _CoreBf = 'bf';
  SQLWhere = 'SELECT * FROM %s WHERE ';
  SQLWhereNonDuplicate = 'SELECT DISTINCT * FROM %s WHERE ';
  SQLDeleteWhere = 'DELETE FROM %s WHERE ';

  cFilter=[tkInteger, tkEnumeration, tkFloat, tkString, tkWChar, tkLString, tkWString, tkVariant, tkInt64, tkUString];

  TTypeKindSql: array[TTypeKind] of string = ('',
    'INTEGER', 'CHAR (1)', 'INTEGER', 'FLOAT', 'VARCHAR (255)',
    'BLOB', 'BLOB', 'BLOB', 'VARCHAR (255)', 'VARCHAR (255)', 'TEXT', 'TEXT',
    'BLOB', 'BLOB', 'BLOB', 'INTEGER', 'BLOB', 'VARCHAR (255)');

function GetFieldsList(CustomClass: TClass; AFieldsList: TStringList): boolean; overload;
function GetFieldsList(BfPInfo: pPropInfo; AFieldsList: TStringList): boolean; overload;
function GetFieldsList(BfPointer: Pointer; AFieldsList: TStringList): boolean; overload;
function GetFieldsValuesList(InstBf: TObject; AFieldsList: TStringList): boolean;
function GetIndexsList(AIndexs: string; AIndexsList: TStringList): boolean;
function ExistField(Instance: TObject; const AFieldName: string): Boolean; overload;
function ExistField(AClass: TClass; const AFieldName: string): Boolean; overload;
procedure CleanObj(Instance: TObject);

implementation

function GetFieldsList(CustomClass: TClass; AFieldsList: TStringList): boolean;
var
  pInfoBf: pPropInfo;
begin
  Result := False;
  if (not IsPublishedProp(CustomClass,_CoreBf)) or
     (not PropIsType(CustomClass,_CoreBf,tkClass)) then
  begin
    Result := GetFieldsList(CustomClass.ClassInfo, AFieldsList);
  end
  else
  begin
    pInfoBf:= GetPropInfo(CustomClass.ClassInfo, _CoreBf);
    if (pInfoBf<>nil) then
      Result := GetFieldsList(pInfoBf, AFieldsList);
  end;
end;

function GetFieldsList(BfPInfo: pPropInfo; AFieldsList: TStringList): boolean;
begin
  Result := GetFieldsList(BfPInfo.PropType^, AFieldsList);
end;

function GetFieldsList(BfPointer: Pointer; AFieldsList: TStringList): boolean; overload;
var
  pCount: integer;
  pList: pPropList;
  i: Integer;
begin
  Result := False;
  if not Assigned(AFieldsList) then Exit;

  pCount := GetPropList(BfPointer, cFilter, nil);
  GetMem(pList, pCount * SizeOf(PPropInfo));
  try
    GetPropList(BfPointer, cFilter, pList);

    AFieldsList.Clear;
    for i := 0 to pCount - 1 do
    begin
      AFieldsList.Values[string(pList[i].Name)] := TTypeKindSql[pList[i].PropType^.Kind];
    end;
  finally
    FreeMem(pList, pCount * SizeOf(PPropInfo));
  end;
end;

function GetFieldsValuesList(InstBf: TObject; AFieldsList: TStringList): boolean;
var
  pCount: integer;
  pList: pPropList;
  i: Integer;
begin
  Result := False;
  if not Assigned(AFieldsList) then Exit;

  pCount := GetPropList(InstBf.ClassInfo, cFilter, nil);
  GetMem(pList, pCount * SizeOf(PPropInfo));
  GetPropList(InstBf.ClassInfo, cFilter, pList);

  AFieldsList.Clear;
  for i := 0 to pCount - 1 do
  begin
    if pList[i].SetProc <> nil then
      AFieldsList.Values[String(pList[i].Name)]:= QuotedStr(GetPropValue(InstBf, pList[i]));
  end;
end;

function GetIndexsList(AIndexs: string; AIndexsList: TStringList): boolean;
begin
  Result:= False;
  if not Assigned(AIndexsList) then Exit;

  AIndexsList.Clear;
  AIndexsList.StrictDelimiter:= True;
  AIndexsList.Delimiter:= ';';
  AIndexsList.QuoteChar:= '"';
  AIndexsList.DelimitedText:= AIndexs;
  Result:= True;
end;

function ExistField(Instance: TObject; const AFieldName: string): Boolean;
var
  pInfo: PPropInfo;
begin
  pInfo:= GetPropInfo(Instance,AFieldName);
  Result:= pInfo <> nil;
end;

function ExistField(AClass: TClass; const AFieldName: string): Boolean;
var
  pInfo: PPropInfo;
begin
  pInfo:= GetPropInfo(AClass,AFieldName);
  Result:= pInfo <> nil;
end;

procedure CleanObj(Instance: TObject);
var
  pCount: Integer;
  pList: pPropList;
  i: Integer;
  v: Variant;
begin
  pCount:= GetPropList(Instance.ClassInfo, cFilter, nil);
  GetMem(pList, pCount * SizeOf(PPropInfo));
  GetPropList(Instance.ClassInfo, cFilter, pList);

  for i := 0 to (pCount - 1) do
  begin
    case pList[i].PropType^.Kind of
      tkInteger: v:= 0;
      tkChar: v:= Char(0);
      tkEnumeration: v:= GetEnumName(pList[i].PropType^,0);
      tkFloat: v:= 0.0;
      tkString: v:= '';
      tkSet: v:= '[]';
      tkClass: v:= 0; // nil
      tkMethod: v:= 0; // nil
      tkWChar: v:= WideChar(0);
      tkUString,tkLString: v:= '';
      tkWString: v:= WideString('');
      tkVariant: v:= Null;
      tkInterface: v:= 0; // nil
      tkInt64: v:= 0;
      // tkUnknown, tkArray , tkRecord e tkDynArray não têm TypeInfo
    end;
    if pList[i].SetProc <> nil then
      SetPropValue(Instance,String(pList[i].Name),v);
  end;
end;

end.
