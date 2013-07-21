unit WorkSession;

interface

uses
  {Core} SQLiteCore, SQLiteDB, WorkClasses,
  SysUtils, Classes, DB;

type
  TForEachColumnEvent = procedure(AColumnName: string; AColumnType: TFieldType) of object;
  TForEachFieldEvent = procedure(AFieldName: string; AFieldValue: Variant) of object;
  TForEachRecordEvent = procedure of object;

type
  TWorkSqlTable = class;

  TWorkSession = class(TSQLiteDatabase)
  private
    FSessionPath: string;
    FCurrentCollection: TCollection;
    FCurrentCollectionItem: TCollectionItem;
    FCurrentDataSet: TDataSet;
    FCurrentList: TStringList;
    procedure NilafyCurrentObj;
    procedure CollectionForEachRecord;
    procedure CollectionForEachColumn(AColumnName: string; AColumnType: TFieldType);
    procedure CollectionForEachField(AFieldName: string; AFieldValue: Variant);
    procedure DataSetForEachRecordBeforeSetValue;
    procedure DataSetForEachRecordAfterSetValue;
    procedure DataSetForEachColumn(AColumnName: string; AColumnType: TFieldType);
    procedure DataSetForEachField(AFieldName: string; AFieldValue: Variant);
    procedure ListForEachField(AFieldName: string; AFieldValue: Variant);
  private
    procedure CreateTable(AName: string; AFieldList: TStringList; APrimaryKeyField: string; AIndexList: TStringList);
    function GetFieldType(AColumnStrType: string): TFieldType;
  protected
    procedure CreateAllTables;
    function RunSql(const SQL: string; ForEachRecordBeforeSetValue: TForEachRecordEvent; ForEachRecordAfterSetValue: TForEachRecordEvent; ForEachColumn: TForEachColumnEvent; ForEachField: TForEachFieldEvent): integer;
  public
    constructor Create(ACorePoint: string);
    destructor Destroy; override;

    procedure Init;
    function GetTable(const SQL: string): TWorkSqlTable;
    procedure GetTablesList(TablesList: TStringList);

    function LoadSqlToCollection(Collection: TCollection; const SQL: string): integer;
    function LoadSqlToDataSet(DataSet: TDataSet; const SQL: string): integer;
  published
    property SessionPath: string read FSessionPath;
  end;

  TWorkSqlTable = class(TSQLiteTable)
  private
    FSession: TWorkSession;
    property Session: TWorkSession read FSession;
  public
    constructor Create(ASession: TWorkSession);
    procedure LoadFromSql(const SQL: string); reintroduce;
  end;

implementation

uses
  WorkEngine, WorkTypes, WorkEntityClasses, Utilities, TypInfo;

{ TWorkSession }

constructor TWorkSession.Create(ACorePoint: string);
begin
  FSessionPath:= ExtractFilePath(ParamStr(0))+ACorePoint;
  inherited Create(FSessionPath);

end;

destructor TWorkSession.Destroy;
begin

  inherited;
end;

procedure TWorkSession.CreateAllTables;
var
  i: Integer;
  FieldList,IndexList: TStringList;
begin
  FieldList:= TStringList.Create;
  IndexList:= TStringList.Create;
  try
    for i := 0 to CoreEngine.CoreEntityList.Count - 1 do
    begin
      if not TableExists(CoreEngine.CoreEntityList[i].EntityName) then
      begin
        CoreEngine.CoreEntityList[i].GetFieldsList(FieldList);
        CoreEngine.CoreEntityList[i].GetIndexsList(IndexList);
        CreateTable(CoreEngine.CoreEntityList[i].EntityName, FieldList, CoreEngine.CoreEntityList[i].PrimaryFieldKey, IndexList);
      end;
    end;
  finally
    IndexList.Free;
    FieldList.Free;
  end;
end;

procedure TWorkSession.CreateTable(AName: string; AFieldList: TStringList; APrimaryKeyField: string; AIndexList: TStringList);
var
  i: Integer;
  sPk,cLast: string;
  Query: TSQLiteQuery;
begin
  if not Assigned(AFieldList) then exit;

  Query.SQL := Format('CREATE TABLE %s (',[AName]);
  for i := 0 to AFieldList.Count - 1 do
  begin
    cLast := ', ';
    if i=AFieldList.Count-1 then cLast := '';

    if AFieldList.Names[i] = APrimaryKeyField then sPk:= ' PRIMARY KEY'
                                              else sPk:= '';

    Query.SQL := Query.SQL+Format('[%s] %s%s',[AFieldList.Names[i], AFieldList.ValueFromIndex[i], sPk+cLast]);
  end;
  Query.SQL := Query.SQL+');';

  for i := 0 to AIndexList.Count - 1 do
  begin
    Query.SQL := Query.SQL+sLineBreak+Format('CREATE INDEX %s ON [%s]([%s]);',['Idx'+AName+JustLetters(AIndexList[i]), AName, AIndexList[i]]);
  end;

  ExecSql(Query.SQL);
end;

procedure TWorkSession.Init;
begin
  CreateAllTables;
end;

function TWorkSession.GetFieldType(AColumnStrType: string): TFieldType;
begin
  {**} if (AColumnStrType = 'INTEGER') then
    result := ftInteger
  else if (AColumnStrType = 'BOOLEAN') then
    result := ftBoolean
  else if (AColumnStrType = 'NUMERIC') or ((AColumnStrType = 'FLOAT') or (AColumnStrType = 'DOUBLE')) or ((AColumnStrType = 'REAL')) then
    result := ftFloat
  else if (AColumnStrType = 'BLOB') then
    result := ftBlob
  else
   result := ftString;
end;

function TWorkSession.GetTable(const SQL: string): TWorkSqlTable;
begin
  result := TWorkSqlTable(inherited GetTable(SQL));
end;

procedure TWorkSession.GetTablesList(TablesList: TStringList);
var
  sql: string;
begin
  if Assigned(TablesList) then
  begin
    FCurrentlist:= TablesList;
    sql := 'SELECT name FROM sqlite_master WHERE type=''table'' ORDER BY name';
    TablesList.Clear;
    RunSql(sql, nil, nil, nil, ListForEachField);
  end;
end;

procedure TWorkSession.NilafyCurrentObj;
begin
  FCurrentCollection:= nil;
  FCurrentCollectionItem:= nil;
  FCurrentDataSet:= nil;
  FCurrentList:= nil;
end;

function TWorkSession.RunSql(const SQL: string; ForEachRecordBeforeSetValue: TForEachRecordEvent; ForEachRecordAfterSetValue: TForEachRecordEvent; ForEachColumn: TForEachColumnEvent; ForEachField: TForEachFieldEvent): integer;
var
  fCols: TStringList;
  fColCount: cardinal;
  fColTypes: TList;
  Stmt: TSQLiteStmt;
  NextSQLStatement: PAnsiChar;
  iStepResult: integer;
  ptr: pointer;
  iNumBytes: integer;
  thisBlobValue: TMemoryStream;
  thisStringValue: pstring;
  thisDoubleValue: pDouble;
  thisIntValue: pInt64;
  thisColType: pInteger;
  i: integer;
  DeclaredColType: PAnsiChar;
  ActualColType: integer;
  ptrValue: PAnsiChar;
  CurrColName: string;
begin
  result := 0;
  fCols := nil;
  fColTypes := nil;
  fColCount := 0;
  try
    if Sqlite3_Prepare_v2(DB, PAnsiChar(AnsiString(SQL)), -1, Stmt, NextSQLStatement) <> SQLITE_OK then
      RaiseError('Error executing SQL', SQL);
    if (Stmt = nil) then
      RaiseError('Could not prepare SQL statement', SQL);

    DoQuery(SQL);
    SetParams(Stmt);
    BindData(Stmt, []);

    iStepResult := Sqlite3_step(Stmt);
    while (iStepResult <> SQLITE_DONE) do
    begin
      case iStepResult of
        SQLITE_ROW:
          begin
            Inc(result);
            if (result = 1) then
            begin
              fCols := TStringList.Create;
              fColTypes := TList.Create;
              fColCount := SQLite3_ColumnCount(stmt);

              { get columns }
              for i := 0 to Pred(fColCount) do
              begin
                CurrColName := string(Sqlite3_ColumnName(stmt, i));
                fCols.Add(AnsiUpperCase(CurrColName));

                new(thisColType);
                DeclaredColType := Sqlite3_ColumnDeclType(stmt, i);
                if DeclaredColType = nil then
                  thisColType^ := Sqlite3_ColumnType(stmt, i)
                else
                  if (DeclaredColType = 'INTEGER') or (DeclaredColType = 'BOOLEAN') then
                    thisColType^ := dtInt
                  else
                    if (DeclaredColType = 'NUMERIC') or
                      (DeclaredColType = 'FLOAT') or
                      (DeclaredColType = 'DOUBLE') or
                      (DeclaredColType = 'REAL') then
                      thisColType^ := dtNumeric
                    else
                      if DeclaredColType = 'BLOB' then
                        thisColType^ := dtBlob
                      else
                        thisColType^ := dtStr;
                fColTypes.Add(thiscoltype);

                if Assigned(ForEachColumn) then ForEachColumn(CurrColName, GetFieldType(string(DeclaredColType^)));
              end;
            end;

            if Assigned(ForEachRecordBeforeSetValue) then ForEachRecordBeforeSetValue;

            { get column values }
            for i := 0 to Pred(fColCount) do
            begin
              ActualColType := Sqlite3_ColumnType(stmt, i);
              CurrColName := string(Sqlite3_ColumnName(stmt, i));

              if (ActualColType <> SQLITE_NULL) then
              begin
                if pInteger(fColTypes[i])^ = dtInt then
                begin
                  new(thisintvalue);
                  thisintvalue^ := Sqlite3_ColumnInt64(stmt, i);
                  if Assigned(ForEachField) then ForEachField(CurrColName, thisintvalue^);
                end
                else
                  if pInteger(fColTypes[i])^ = dtNumeric then
                  begin
                    new(thisdoublevalue);
                    thisdoublevalue^ := Sqlite3_ColumnDouble(stmt, i);
                    if Assigned(ForEachField) then ForEachField(CurrColName, thisdoublevalue^);
                  end
                  else
                    if pInteger(fColTypes[i])^ = dtBlob then
                    begin
                      iNumBytes := Sqlite3_ColumnBytes(stmt, i);
                      if iNumBytes = 0 then
                        thisblobvalue := nil
                      else
                      begin
                        thisblobvalue := TMemoryStream.Create;
                        thisblobvalue.Position := 0;
                        ptr := Sqlite3_ColumnBlob(stmt, i);
                        thisblobvalue.WriteBuffer(ptr^, iNumBytes);
                      end;
                      //if Assigned(ForEachField) then ForEachField(CurrColName, thisblobvalue);
                    end
                    else
                    begin
                      new(thisstringvalue);
                      ptrValue := Sqlite3_ColumnText(stmt, i);
                      setstring(thisstringvalue^, ptrvalue, strlen(ptrvalue));
                      if Assigned(ForEachField) then ForEachField(CurrColName, thisstringvalue^);
                    end;
              end; //If
            end; //For

            if Assigned(ForEachRecordAfterSetValue) then ForEachRecordAfterSetValue;
          end;
        SQLITE_BUSY:
          raise ESqliteException.CreateFmt('Could not prepare SQL statement', [SQL, 'SQLite is Busy']);
      else
        begin
          SQLite3_reset(stmt);
          RaiseError('Could not retrieve data', SQL);
        end;
      end;
      iStepResult := Sqlite3_step(Stmt);
    end;
  finally
    if Assigned(fCols) then FreeAndNil(fCols);
    if Assigned(fColTypes) then FreeAndNil(fColTypes);
    if Assigned(Stmt) then Sqlite3_Finalize(stmt);
    NilafyCurrentObj;
  end;
end;

function TWorkSession.LoadSqlToCollection(Collection: TCollection; const SQL: string): integer;
begin
  result := 0;
  if not Assigned(Collection) then exit;
  FCurrentCollection:= Collection;
  result := RunSql(SQL, CollectionForEachRecord, nil, CollectionForEachColumn, CollectionForEachField);
end;

function TWorkSession.LoadSqlToDataSet(DataSet: TDataSet; const SQL: string): integer;
begin
  result := 0;
  if not Assigned(DataSet) then exit;
  FCurrentDataSet:= DataSet;
  FCurrentDataSet.Active:= false;
  FCurrentDataSet.Fields.Clear;
  FCurrentDataSet.FieldDefs.Clear;
  result := RunSql(SQL, DataSetForEachRecordBeforeSetValue, DataSetForEachRecordAfterSetValue, DataSetForEachColumn, DataSetForEachField);
end;

procedure TWorkSession.CollectionForEachRecord;
begin
  FCurrentCollectionItem := TWorkEntityList(FCurrentCollection).Add;
end;

procedure TWorkSession.CollectionForEachColumn(AColumnName: string; AColumnType: TFieldType);
begin
//
end;

procedure TWorkSession.CollectionForEachField(AFieldName: string; AFieldValue: Variant);
var
  ItemBf: TObject;
begin
  if not Assigned(FCurrentCollectionItem) then exit;
  ItemBf := TypInfo.GetObjectProp(TWorkEntity(FCurrentCollectionItem),_CoreBf);
  if (ItemBf=nil) or (not WorkTypes.ExistField(ItemBf, AFieldName)) then exit;
  TypInfo.SetPropValue(ItemBf, AFieldName, AFieldValue);
end;

procedure TWorkSession.DataSetForEachRecordBeforeSetValue;
begin
  if not FCurrentDataSet.Active then FCurrentDataSet.Active := true;
  FCurrentDataSet.Append;
end;

procedure TWorkSession.DataSetForEachRecordAfterSetValue;
begin
  if FCurrentDataSet.State in [dsEdit, dsInsert] then FCurrentDataSet.Post;
end;

procedure TWorkSession.DataSetForEachColumn(AColumnName: string; AColumnType: TFieldType);
var
  iSize: integer;
  FieldDef: TFieldDef;
begin
  case AColumnType of
    ftString: iSize:= 255;
    ftInteger: iSize:= 4;
    ftFloat: iSize:= 8;
    else iSize:= 1;
  end;

  FieldDef := FCurrentDataSet.FieldDefs.AddFieldDef;
  try
    FieldDef.Name := AColumnName;
    FieldDef.DataType := AColumnType;
    FieldDef.Size := iSize;
    FieldDef.CreateField(FCurrentDataSet);
  except
    FieldDef.Free;
    raise;
  end;
end;

procedure TWorkSession.DataSetForEachField(AFieldName: string; AFieldValue: Variant);
begin
  FCurrentDataSet.FieldByName(AFieldName).Value := AFieldValue;
end;

procedure TWorkSession.ListForEachField(AFieldName: string; AFieldValue: Variant);
begin
  if not Assigned(FCurrentList) then exit;
  FCurrentList.Add(AFieldValue);
end;

{ TWorkSqlTable }

constructor TWorkSqlTable.Create(ASession: TWorkSession);
begin
  inherited Create;
  FSession := ASession;
end;

procedure TWorkSqlTable.LoadFromSql(const SQL: string);
begin
  inherited LoadFromSql(Session, SQL, []);
end;

end.
