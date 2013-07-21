unit WorkEntityClasses;

interface

uses
  {Core} WorkSession, WorkClasses,
  SysUtils, Classes, Variants;

type
  TWorkEntity = class;
  TWorkEntityClass = class of TWorkEntity;
  TWorkEntityBf = class;
  TWorkEntityBfClass = class of TWorkEntityBf;

  EEntity = class(Exception,ICustomInterface)
  private
    FOwnerInterface: IUnknown;
    FEntity : TWorkEntity;
    FFieldNames : string;
    FValues : string;
    function GetFieldNames: string;
  	function GetMessage: string;
  protected
    { IUnknown }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
  public
    constructor Create(const Msg: string; AEntity: TWorkEntity=nil; const AFieldNames: string=''; const AValues: string='');
    property Entity: TWorkEntity read FEntity;
    property FieldNames: string read GetFieldNames;
    property Values: string read FValues;
  end;

  TWorkEntityBf = class(TCustomPersistent)
  private
    FOwner: TWorkEntity;
  public
    constructor Create(AOwner: TWorkEntity); virtual;
    destructor Destroy; override;
    property Owner: TWorkEntity read FOwner;
  end;

  EWorkEntity = class(Exception);
  TWorkEntity = class(TCustomCollectionItem)
  private
    FSession: TWorkSession;
    FOwner: TPersistent;
    FSqlTable: TWorkSqlTable;
    FBf: TWorkEntityBf;
  protected
    function GetBf: TWorkEntityBf;
    function GetSqlTable: TWorkSqlTable;
    function GetValuePrimaryKey: variant;
    procedure AssignSqlToBf;
    procedure Insert;
    procedure Update;
  public
    constructor Create(Collection: TPersistent; ASession: TWorkSession); reintroduce;
    destructor Destroy; override;

    class function BfClass: TWorkEntityBfClass; virtual;
    class function GetEntityName: string; virtual; abstract;
    class function GetEntityPrimaryKey: string; virtual; abstract;
    class function GetEntityIndexs: string; virtual; abstract;
    class function GetFieldsList(AFieldsList: TStringList): boolean;
    class function GetIndexsList(AIndexsList: TStringList): boolean;
    function GetRecordsCount: Integer;

    function ExistRecord(const AFieldName: String; AValue: Variant; const AIsPrimaryKey: Boolean=True): Boolean; overload;
    function ExistRecord(ASQL: String; const AIsPrimaryKey: Boolean=True): Boolean; overload;
    procedure Validate; virtual;
    function HasRelations(ARaise: Boolean=True): Boolean; virtual;
    procedure New;
    procedure Save; virtual;
    function Delete(APrimaryKeyValue: Variant): Boolean; virtual;

    property Session: TWorkSession read FSession;
    property SqlTable: TWorkSqlTable read GetSqlTable;
  published
    property bf: TWorkEntityBf read GetBf;
    property Owner: TPersistent read FOwner;
  end;

  TWorkEntityList = class(TCustomCollection)
  private
    FSession: TWorkSession;
  protected
    function GetItem(Index: Integer): TWorkEntity;
    procedure SetItem(Index: Integer; const Value: TWorkEntity);
  public
    constructor Create(ASession: TWorkSession); reintroduce;
    class function EntityClass: TWorkEntityClass; virtual;
    function Add: TWorkEntity;
    procedure GetBySQL(ASQL: String);
    procedure GetAll(AClear: Boolean=True);
    property Items[Index: Integer]: TWorkEntity read GetItem write SetItem; default;
    property Session: TWorkSession read FSession;
  end;

  TCoreControllerClass = class of TCoreController;
  ICoreController = interface
    ['{DF8B5988-AFD3-4342-BDF2-4DC50B072A66}']
    function GetOwner: TPersistent;
    function GetObjectInstance: TObject;
  end;

  TCoreController = class(TCustomCollectionItem, ICoreController)
  private
    FOwner: TPersistent;
    FSession: TWorkSession;
  protected
    function GetOwner: TPersistent; override;
    function GetObjectInstance: TObject;
    function GetSession: TWorkSession;
  public
    constructor Create(AOwner: TPersistent; ASession: TWorkSession); reintroduce; virtual;
    destructor Destroy; override;
    function Owner: TPersistent;
    property Session: TWorkSession read GetSession;
  end;

implementation

uses
  TypInfo, WorkTypes, Utilities;

{ TWorkEntityBf }

constructor TWorkEntityBf.Create(AOwner: TWorkEntity);
begin
  inherited Create;
  FOwner := AOwner;
end;

destructor TWorkEntityBf.Destroy;
begin

  inherited;
end;

{ TWorkEntity }

procedure TWorkEntity.AssignSqlToBf;
var
  BfFields: TStringList;
  i: Integer;
  v: Variant;
begin
  if SqlTable.Count<>1 then exit;

  BfFields:= TStringList.Create;
  try
    GetFieldsList(BfFields);
    for i := 0 to BfFields.Count - 1 do
    begin
      if not SqlTable.ColumnExist(BfFields.Names[i]) then Continue;

      //ToDo
      v:= SqlTable.FieldAsString(SqlTable.FieldIndex[BfFields.Names[i]]);

      TypInfo.SetPropValue(Bf, BfFields.Names[i], v);
    end;
  finally
    BfFields.Free;
  end;
end;

class function TWorkEntity.BfClass: TWorkEntityBfClass;
begin
  result := nil;
end;

constructor TWorkEntity.Create(Collection: TPersistent; ASession: TWorkSession);
begin
  FOwner := Collection;
  if Collection is TCollection then
    inherited Create(TCollection(Collection))
  else
    inherited Create(nil);

  FBf:= BfClass.Create(Self);
  FSqlTable:= nil;;
  FSession:= ASession;
end;

destructor TWorkEntity.Destroy;
begin
  FreeAndNil(FSqlTable);
  FreeAndNil(FBf);
  inherited;
end;

function TWorkEntity.GetBf: TWorkEntityBf;
begin
  Result:= FBf;
end;

function TWorkEntity.GetRecordsCount: Integer;
begin
  SqlTable.LoadFromSql('SELECT * FROM '+GetEntityName);
  Result:= SqlTable.Count;
end;

class function TWorkEntity.GetFieldsList(AFieldsList: TStringList): boolean;
begin
  Result:= WorkTypes.GetFieldsList(BfClass, AFieldsList);
end;

class function TWorkEntity.GetIndexsList(AIndexsList: TStringList): boolean;
begin
  Result:= WorkTypes.GetIndexsList(GetEntityIndexs, AIndexsList);
end;

function TWorkEntity.GetSqlTable: TWorkSqlTable;
begin
  if not Assigned(FSqlTable) then
    FSqlTable:= TWorkSqlTable.Create(Session);
  Result:= FSqlTable;
end;

function TWorkEntity.GetValuePrimaryKey: variant;
begin
  Result:= TypInfo.GetPropValue(self.bf,GetEntityPrimaryKey);
end;

function TWorkEntity.HasRelations(ARaise: Boolean): Boolean;
begin
  Result:= False;
end;

procedure TWorkEntity.Insert;
var
  Fields: TStringList;
  i: Integer;
  sSql,sF,sV: string;
begin
  Fields:= TStringList.Create;
  try
    sSql := 'INSERT INTO '+GetEntityName;
    sF := '(';
    sV := ') VALUES (';

    WorkTypes.GetFieldsValuesList(bf, Fields);
    for i := 0 to Fields.Count - 1 do
    begin
      sF := sF+Fields.Names[i];
      sV := sV+Fields.ValueFromIndex[i];
      if Fields.Count-1<>i then
      begin
        sF := sF+',';
        sV := sV+',';
      end;
    end;
    sSql := sSql+sF+sV+');';
  finally
    Fields.Free;
  end;
  Session.ExecSQL(sSql);
end;

procedure TWorkEntity.Update;
var
  Fields: TStringList;
  i: Integer;
  sSql: String;
  isFirst: Boolean;
begin
  isFirst:= True;
  Fields:= TStringList.Create;
  try
    sSql:= 'UPDATE '+GetEntityName+' SET ';
    //Info: Update all fields of table except PrimaryKey
    WorkTypes.GetFieldsValuesList(bf, Fields);
    for i := 0 to Fields.Count - 1 do
    begin
      if Fields.Names[i] = GetEntityPrimaryKey then continue;
      if not isFirst then sSql := sSql+', ';
      sSql:= sSql+Format('%s=%s',[Fields.Names[i], Fields.ValueFromIndex[i]]);
      isFirst:= False;
    end;
    sSql:= sSql+Format(' WHERE %s=%s',[GetEntityPrimaryKey, QuotedStr(GetValuePrimaryKey)]); //ToDo
  finally
    Fields.Free;
  end;
  Session.ExecSQL(sSql);
end;

procedure TWorkEntity.Validate;
begin

end;

procedure TWorkEntity.New;
begin
  WorkTypes.CleanObj(Self.bf);
end;

procedure TWorkEntity.Save;
begin
  Validate;
end;

function TWorkEntity.Delete(APrimaryKeyValue: Variant): Boolean;
var
  DeleteSql: String;
  QuotedKey: Boolean;
begin
  QuotedKey:= False;
  if VarIsNull(APrimaryKeyValue) then
  begin
    QuotedKey:= True;
  end
  else if VarIsStr(APrimaryKeyValue) then
  begin
    if VarToStr(APrimaryKeyValue) = '' then
      QuotedKey:= True
    else
      QuotedKey:= not IsNumber(VarToStr(APrimaryKeyValue));
  end;
  DeleteSql:= Format(SQLDeleteWhere+'%s=%s',[GetEntityName,GetEntityPrimaryKey,IIf(QuotedKey, QuotedStr(APrimaryKeyValue), APrimaryKeyValue)]);
  Session.ExecSQL(DeleteSql);
  Result:= True;
end;

function TWorkEntity.ExistRecord(const AFieldName: String; AValue: Variant; const AIsPrimaryKey: Boolean): Boolean;
var
  QuotedKey: Boolean;
begin
  QuotedKey:= False;
  if VarIsNull(AValue) then
  begin
    QuotedKey:= True;
  end
  else if VarIsStr(AValue) then
  begin
    if VarToStr(AValue) = '' then
      QuotedKey:= True
    else
      QuotedKey:= not IsNumber(VarToStr(AValue));
  end;
  Result:= ExistRecord(Format('SELECT * FROM %s WHERE %s=%s',[GetEntityName,AFieldName,IIf(QuotedKey,QuotedStr(AValue),AValue)]),AIsPrimaryKey);
end;

function TWorkEntity.ExistRecord(ASQL: String; const AIsPrimaryKey: Boolean): Boolean;
begin
  if ASQL = '' then Exit(False);
  SqlTable.LoadFromSql(ASQL);
  if AIsPrimaryKey and (SqlTable.Count > 1) then
    raise EWorkEntity.Create('Duplicate records: '+ASQL);
  Result:= SqlTable.Count > 0;
end;

{ TWorkEntityList }

constructor TWorkEntityList.Create(ASession: TWorkSession);
begin
  inherited Create(EntityClass);
  FSession:= ASession;
end;

class function TWorkEntityList.EntityClass: TWorkEntityClass;
begin
  Result:= TWorkEntity;
end;

function TWorkEntityList.Add: TWorkEntity;
begin
  Result:= TWorkEntity(EntityClass.Create(Self, Session));
end;

procedure TWorkEntityList.GetAll(AClear: Boolean);
begin
  if AClear then Clear;
  GetBySQL('SELECT * FROM '+EntityClass.GetEntityName);
end;

procedure TWorkEntityList.GetBySQL(ASQL: String);
begin
  Session.LoadSqlToCollection(Self,ASQL);
end;

function TWorkEntityList.GetItem(Index: Integer): TWorkEntity;
begin
  Result:= TWorkEntity(inherited GetItem(Index));
end;

procedure TWorkEntityList.SetItem(Index: Integer; const Value: TWorkEntity);
begin
  inherited SetItem(Index, Value);
end;

{ TCoreController }

constructor TCoreController.Create(AOwner: TPersistent; ASession: TWorkSession);
begin
  if AOwner is TCollection then inherited Create(TCollection(AOwner))
                           else inherited Create(nil);
  FOwner := AOwner;
  FSession := ASession;
end;

destructor TCoreController.Destroy;
begin

  inherited;
end;

function TCoreController.GetOwner: TPersistent;
begin
  result := FOwner;
end;

function TCoreController.GetObjectInstance: TObject;
begin
  result := self;
end;

function TCoreController.GetSession: TWorkSession;
begin
  result := FSession;
end;

function TCoreController.Owner: TPersistent;
begin
  result := GetOwner;
end;

{ EEntity }

function EEntity.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else  Result := E_NOINTERFACE;
end;

function EEntity._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function EEntity._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

constructor EEntity.Create(const Msg: string;AEntity: TWorkEntity=nil; const AFieldNames: string=''; const AValues: string='');
begin
  inherited Create(Msg);
  FEntity := AEntity;
  FFieldNames := AFieldNames;
  FValues := AValues;
end;

function EEntity.GetFieldNames: string;
begin
  Result:= FFieldNames;
end;

function EEntity.GetMessage: string;
begin
  Result:= '';
end;

end.
