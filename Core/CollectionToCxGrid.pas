unit CollectionToCxGrid;

interface

uses
  Classes, Windows, TypInfo, Contnrs, SysUtils, StrUtils, WorkTypes,
  cxCustomData, cxGridTableView, cxDataStorage, cxGridBandedTableView,
  cxDropDownEdit, cxLabel, cxCalc, cxtimeEdit, cxTL, cxTLData, Variants,
  cxCurrencyEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxCalendar,
  cxCheckBox, cxInplaceContainer, cxGridCustomTableView, cxGridCardView;

type
  TOnAfterCreateGridColum = procedure(Sender: TObject; FieldName: string; Column: TcxGridColumn) of object;
  TOnAfterCreateTreeListColum = procedure(Sender: TObject; FieldName: string; Column: TcxTreeListColumn) of object;

  TSearchType = (stExact,stBegining,stContaining);

  TWorkField = class(TCollectionItem)
  private
    FFieldName: String;
    FTag: Integer;
    FID: Integer;
    FData: TObject;
    FUserData: Integer;
    procedure SetFieldName(const Value: String);
    procedure SetID(const Value: Integer);
    procedure SetTag(const Value: Integer);
    procedure SetData(const Value: TObject);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldName: String read FFieldName write SetFieldName;
    property ID: Integer read FID write SetID;
    property Tag: Integer read FTag write SetTag;
    property Data: TObject read FData write SetData;
    property UserData: Integer read FUserData write FUserData;
  end;

  TWorkFieldList = class(TCollection)
  private
    function GetItem(AIndex: Integer): TWorkField;
    procedure SetItem(AIndex: Integer; const Value: TWorkField);
  public
    constructor Create(AOnwer: TObject);
    procedure GetFieldsName(AList:TStrings);
    procedure Add(AList: TStrings); overload;
    function Add: TWorkField; overload;
    function Add(AFieldName: String; AID: Integer=0): TWorkField; overload;
    property Items[Index: Integer]: TWorkField read GetItem write SetItem; default;
  end;

  TCustomBaseCollectionDataSource = class(TcxTreeListCustomDataSource)
  private
    FControlsList: TObjectList;
    FFieldList: TWorkFieldList;
    FOnAfterCreateGridColum: TOnAfterCreateGridColum;
    FOnAfterCreateTreeListColumn: TOnAfterCreateTreeListColum;
    FOnDestroying: TNotifyEvent;
    FName: String;
    procedure SetOnAfterCreateGridColum(const Value: TOnAfterCreateGridColum);
    procedure SetOnAfterCreateTreeListColumn(const Value: TOnAfterCreateTreeListColum);
    procedure SetName(const Value: String);
  protected
    procedure DoAfterCreateGridColum(FieldName: string; Column: TcxGridColumn);
    procedure DoAfterCreateTreeListColum(FieldName: string; Column: TcxTreeListColumn);
    property ControlsList: TObjectList read FControlsList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AssignControl(Control: TObject); virtual;
    procedure UnAssignControl(Control: TObject); virtual;
    function AddColumn(FieldName: String): TObject; virtual;
    property FieldList: TWorkFieldList read FFieldList;
    Property Name:String read FName write SetName;
    { Events }
    property OnAfterCreateGridColum: TOnAfterCreateGridColum read FOnAfterCreateGridColum write SetOnAfterCreateGridColum;
    property OnAfterCreateTreeListColumn: TOnAfterCreateTreeListColum read FOnAfterCreateTreeListColumn write SetOnAfterCreateTreeListColumn;
    property OnDestroying: TNotifyEvent read FOnDestroying write FOnDestroying;
  end;

  TCustomCollectionDataSource = class(TCustomBaseCollectionDataSource)
  private
    FList:TObject;
    FFields: TStringList;
    FModified: boolean;
    FIsUpdating: Integer;
    FBands: TStringList;
    function GetIsUpdating: boolean;
    function GetCollection: TObject;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); virtual;
    procedure CreateColumns(Comp: TObject); virtual;
    procedure CreateColumnsAllTableView; virtual;
    procedure InternalDataChanged;
    function GetFieldName(AIndex: Integer): String;
  public
    constructor Create(AList:TObject); reintroduce;
    destructor Destroy; override;
    procedure AssignControl(Control: TObject); override;
    procedure UnAssignControl(Control: TObject); override;

    procedure AssignTableView(ATableView: TcxCustomGridTableView);
    procedure UnassignTableView(ATableView: TcxCustomGridTableView);
    procedure RefreshTableView;
    procedure BeginUpdate;
    procedure EndUpdate;
    property Modified: boolean read FModified write FModified;
    function GetColumnByFieldName(ATableView: TcxGridBandedTableView; AFieldName: String): TcxGridBandedColumn; overload;
    function GetColumnByFieldName(ATableView: TcxGridTableView; AFieldName: String): TcxGridColumn; overload;
    function GetColumnByFieldName(ATableView: TcxGridCardView; AFieldName: String): TcxGridCardViewRow; overload;
    procedure DataChanged; override;
    function GetFieldValue(Index: Integer; FieldName: String): Variant; virtual;
    property IsUpdating: boolean read GetIsUpdating;
    property Fields: TStringList read FFields;
    property Bands: TStringList read FBands;
    Property Collection:TObject read GetCollection;
  end;

  TCollectionDataSource = class(TCustomCollectionDataSource)
  private
    FCollection: TCollection;
    FExtendedValue: Boolean;
    FOnGetData: TNotifyEvent;
    procedure SetOnGetData(const Value: TNotifyEvent);
  protected
    procedure SetCollection(const Value: TCollection); virtual;
    procedure DeleteRecord(ARecordHandle: TcxDataRecordHandle); override;
    function GetRecordCount: Integer; override;
    function InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle; override;
    function AppendRecord: TcxDataRecordHandle; override;
    function GetCollection: TCollection; virtual;
  public
    constructor Create(ACollection: TCollection); reintroduce; virtual;
    destructor Destroy; override;
    procedure ChangeCollection(ACollection: TCollection);
    procedure DoGetdata; virtual;
    function IsGeralDefined: Boolean; virtual;
    property Collection: TCollection read GetCollection write SetCollection;
    property ExtendedValue:Boolean read FExtendedValue write FExtendedValue;
    property OnGetData: TNotifyEvent read FOnGetData write SetOnGetData;
  end;

  TCollectionDataSourceUser = class(TCollectionDataSource)
  private
    function DisplayFormat: String;
  protected
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle; const AValue: Variant); override;

    procedure SetCollection(const Value: TCollection); override;
    procedure CreateColumns(Comp: TObject); override;
    procedure LoadAllFields;
  public
    constructor Create(ACollection: TCollection; const AFields: string = ''); reintroduce;
    destructor Destroy; override;

    function GetFieldValue(Index: Integer; FieldName: string): Variant; Override;
  end;

  TCollectionTreeDataSourceUser = class(TCollectionDataSourceUser)
  private
    FKeyField: String;
    FParentField: String;
  protected
    function GetParentRecordHandle(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle; override;
    function AppendRecord: TcxDataRecordHandle; override;
  public
    constructor Create(ACollection: TCollection; AKeyField, AParentField: string; const AFields: string = ''); reintroduce;
    destructor Destroy; override;
    procedure AssignControl(Control:TObject; ABandsInFieldList: Boolean); reintroduce;
    procedure AssignTreeView(AVirtualTreeList: TcxVirtualTreeList; ABandsInFieldList: Boolean=False);
    function GetColumnByFieldName(ATree: TcxVirtualTreeList; FieldName: string): TcxTreeListColumn;
  end;

  procedure FormatColumnByValueTypeClass(FieldName: string; Obj,
    GridOrTreeColumn: TObject; ValueTypeClass: TcxValueTypeClass; ReadOnly,
    Extended: Boolean; DisplayFormat: String);
  Function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Grid: TcxGridTableView;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxGridColumn; overload;
  Function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Grid: TcxGridCardView;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxGridCardViewRow; overload;
  Function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Tree: TcxVirtualTreeList;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxTreeListColumn; overload;
  Function CreateColumn(Sender:TObject;FieldName: string; Obj, GridOrTree: TObject;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TObject; overload;

implementation

uses
  WorkEntityClasses;

{ TWorkField }

procedure TWorkField.Assign(Source: TPersistent);
begin
  FFieldName:= TWorkField(source).FFieldName;
  FTag:= TWorkField(source).FTag;
  FID:= TWorkField(source).FID;
  FData:= TWorkField(source).FData;
end;

constructor TWorkField.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FData:= nil;
end;

procedure TWorkField.SetData(const Value: TObject);
begin
  FData:= Value;
end;

procedure TWorkField.SetFieldName(const Value: string);
begin
  FFieldName:= Value;
end;

procedure TWorkField.SetID(const Value: Integer);
begin
  FID:= Value;
end;

procedure TWorkField.SetTag(const Value: Integer);
begin
  FTag:= Value;
end;

{ TWorkFieldList }

function TWorkFieldList.Add: TWorkField;
begin
  Result:= inherited Add as TWorkField;
end;

function TWorkFieldList.Add(AFieldName: String; AID: Integer = 0): TWorkField;
begin
  Result:= Add;
  Result.FieldName:= AFieldName;
  Result.ID:= AID;
end;

procedure TWorkFieldList.Add(AList: TStrings);
var
  i: Integer;
begin
  for i := 0 to AList.Count - 1 do
    Add(AList[i]);
end;

constructor TWorkFieldList.Create(AOnwer: TObject);
begin
  inherited Create(TWorkField);
end;

function TWorkFieldList.GetItem(AIndex: Integer): TWorkField;
begin
  Result := inherited GetItem(AIndex) as TWorkField;
end;

procedure TWorkFieldList.SetItem(AIndex: Integer; const Value: TWorkField);
begin
  inherited SetItem(AIndex,Value);
end;

procedure TWorkFieldList.GetFieldsName(AList: TStrings);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    AList.Add(Items[i].FieldName);
end;

{ TCustomBaseCollectionDataSource }

constructor TCustomBaseCollectionDataSource.Create;
begin
  FControlsList:= TObjectList.Create(False);
  FFieldList:= TWorkFieldList.Create(Self);
end;

destructor TCustomBaseCollectionDataSource.Destroy;
begin
  if Assigned(OnDestroying) then OnDestroying(Self);
  FOnAfterCreateGridColum := nil;
  FOnAfterCreateTreeListColumn := nil;
  FControlsList.Free;
  FFieldList.Free;
  inherited;
end;

procedure TCustomBaseCollectionDataSource.AssignControl(Control: TObject);
begin
  if FControlsList.IndexOf(Control) = -1 then
    FControlsList.add(Control);
end;

procedure TCustomBaseCollectionDataSource.UnAssignControl(Control: TObject);
var
  Idx: Integer;
begin
  Idx:= FControlsList.IndexOf(Control);
  if Idx >= 0 then
    FControlsList.Delete(Idx);
end;

procedure TCustomBaseCollectionDataSource.DoAfterCreateGridColum(FieldName: string; Column: TcxGridColumn);
begin
  if Assigned(FOnAfterCreateGridColum) then
    FOnAfterCreateGridColum(Self,FieldName,Column);
end;

procedure TCustomBaseCollectionDataSource.SetOnAfterCreateGridColum(
  const Value: TOnAfterCreateGridColum);
begin
  FOnAfterCreateGridColum:= Value;
end;

procedure TCustomBaseCollectionDataSource.DoAfterCreateTreeListColum(
  FieldName: string; Column: TcxTreeListColumn);
begin
  if Assigned(FOnAfterCreateTreeListColumn) then
    FOnAfterCreateTreeListColumn(Self,FieldName,Column);
end;

procedure TCustomBaseCollectionDataSource.SetOnAfterCreateTreeListColumn(
  const Value: TOnAfterCreateTreeListColum);
begin
  FOnAfterCreateTreeListColumn:= Value;
end;

function TCustomBaseCollectionDataSource.AddColumn(FieldName: String):TObject;
begin
  Result:= nil;
end;

procedure TCustomBaseCollectionDataSource.SetName(const Value: String);
begin
  FName:= Value;
end;

procedure TCustomCollectionDataSource.AssignControl(Control: TObject);
begin
  inherited;
  if Control is TcxCustomGridTableView then
  begin
    TcxCustomGridTableView(Control).DataController.CustomDataSource:= Self;
    TcxCustomGridTableView(Control).BeginUpdate;
    try
      CreateColumns(Control);
    finally
      TcxCustomGridTableView(Control).EndUpdate;
    end;
  end
  else if Control is TcxVirtualTreeList then
  begin
    TcxVirtualTreeList(Control).CustomDataSource:= Self;
    TcxVirtualTreeList(Control).BeginUpdate;
    try
      CreateColumns(Control);
    finally
      TcxVirtualTreeList(Control).EndUpdate;
    end;
  end
  else
    Assert(False);
end;

procedure TCustomCollectionDataSource.AssignTableView(
  ATableView: TcxCustomGridTableView);
begin
  AssignControl(ATableView);
end;

procedure TCustomCollectionDataSource.BeginUpdate;
var
  i: Integer;
  Item: TObject;
begin
  Inc(FIsUpdating);
  for i := 0 to ControlsList.Count - 1 do
  begin
    Item:= ControlsList[i];
    if Item is TcxCustomGridTableView then
      TcxCustomGridTableView(Item).BeginUpdate;
  end;
end;

constructor TCustomCollectionDataSource.Create(AList:TObject);
begin
  FList:= AList;
  inherited Create;
  FIsUpdating:= 0;
  FFields:= TStringList.Create;
  FBands:= TStringList.Create;
end;

procedure TCustomCollectionDataSource.CreateColumns(Comp: TObject);
var
  i: Integer;
begin
  if Comp is TcxGridBandedTableView then
  begin
    TcxGridBandedTableView(Comp).ClearItems;
    TcxGridBandedTableView(Comp).Bands.Clear;
  end
  else if Comp is TcxCustomGridTableView then
  begin
    TcxCustomGridTableView(Comp).ClearItems;
  end
  else if Comp is TcxVirtualTreeList then
  begin
    for i := TcxVirtualTreeList(Comp).ColumnCount - 1 downto 0 do
      TcxVirtualTreeList(Comp).Columns[0].Free;
  end;
end;

procedure TCustomCollectionDataSource.CreateColumnsAllTableView;
var
  i: Integer;
  Item: TObject;
  TableView: TcxCustomGridTableView;
begin
  BeginUpdate;
  try
    for i := 0 to ControlsList.Count - 1 do
    begin
      Item:= ControlsList[i];
      if Item is TcxGridTableView then
      begin
        TableView:= TcxCustomGridTableView(Item);
        CreateColumns(TableView);
      end;
    end;
    RefreshTableView;
  finally
    EndUpdate;
  end;
end;

procedure TCustomCollectionDataSource.DataChanged;
begin
  if IsUpdating then Exit;
  InternalDataChanged;
end;

destructor TCustomCollectionDataSource.Destroy;
begin
  FBands.Free;
  FFields.Free;
  inherited;
end;

procedure TCustomCollectionDataSource.EndUpdate;
var
  i: Integer;
  Item: TObject;
begin
  try
    for i := 0 to ControlsList.Count - 1 do
    begin
      Item:= ControlsList[i];
      if Item is TcxCustomGridTableView then
        TcxCustomGridTableView(Item).EndUpdate;
    end;
  finally
    Dec(FIsUpdating);
    if FIsUpdating < 0 then
      FIsUpdating:= 0;
  end;
  if FIsUpdating = 0 then DataChanged;
end;

function TCustomCollectionDataSource.GetColumnByFieldName(ATableView: TcxGridBandedTableView;
  AFieldName: String): TcxGridBandedColumn;
var
  i: Integer;
  Column: TcxGridBandedColumn;
begin
  Result:= nil;
  for i := 0 to ATableView.ColumnCount - 1 do
  begin
    Column:= ATableView.Columns[i];
    if SameText(TWorkField(Column.DataBinding.Data).FieldName,AFieldName) then
      Exit(Column);
  end;
end;

function TCustomCollectionDataSource.GetColumnByFieldName(ATableView: TcxGridTableView;
  AFieldName: String): TcxGridColumn;
var
  i: Integer;
  Column: TcxGridColumn;
begin
  Result:= nil;
  for i := 0 to ATableView.ColumnCount - 1 do
  begin
    Column:= ATableView.Columns[i];
    if SameText(TWorkField(Column.DataBinding.Data).FieldName,AFieldName) then
      Exit(Column);
  end;
end;

function TCustomCollectionDataSource.GetColumnByFieldName(ATableView: TcxGridCardView; AFieldName: String): TcxGridCardViewRow;
var
  i: Integer;
  Row: TcxGridCardViewRow;
begin
  Result:= nil;
  for i := 0 to ATableView.RowCount - 1 do
  begin
    Row:= ATableView.Rows[i];
    if SameText(TWorkField(Row.DataBinding.Data).FieldName,AFieldName) then
      Exit(Row);
  end;
end;

function TCustomCollectionDataSource.GetFieldName(AIndex: Integer): String;
begin
  Result:= FFields.Names[AIndex];
  if Result = '' then
    Result:= FFields.Strings[AIndex];
end;

function TCustomCollectionDataSource.GetFieldValue(Index: Integer;
  FieldName: string): Variant;
begin
  Result:= null;
end;

function TCustomCollectionDataSource.GetIsUpdating: boolean;
begin
  Result:= FIsUpdating <> 0;
end;

function TCustomCollectionDataSource.GetCollection: TObject;
begin
  Result:= FList;
end;

procedure TCustomCollectionDataSource.InternalDataChanged;
begin
  inherited DataChanged;
end;

procedure TCustomCollectionDataSource.Notify(Ptr: Pointer; Action: TListNotification);
begin
  DataChanged;
end;

procedure TCustomCollectionDataSource.RefreshTableView;
var
  i: Integer;
  Item: TObject;
begin
  DataChanged;
  for i := 0 to ControlsList.Count - 1 do
  begin
    Item:= ControlsList[i];
    if Item is TcxCustomGridTableView then
      TcxCustomGridTableView(Item).DataController.Refresh;
  end;
end;

procedure TCustomCollectionDataSource.UnAssignControl(Control: TObject);
begin
  inherited;
end;

procedure TCustomCollectionDataSource.UnassignTableView(ATableView: TcxCustomGridTableView);
begin
  UnAssignControl(ATableView);
end;

{ TCollectionDataSource }

function TCollectionDataSource.AppendRecord: TcxDataRecordHandle;
begin
  if not Assigned(FCollection) then
    Exit(TcxDataRecordHandle(-1));
  Result:= TcxDataRecordHandle(FCollection.Add.Index);
  if not Modified then
    FModified := True;
  DataChanged;
end;

procedure TCollectionDataSource.ChangeCollection(ACollection: TCollection);
begin
  if ACollection <> Collection then
  begin
    FCollection:= ACollection;
    DataChanged;
  end;
end;

constructor TCollectionDataSource.Create(ACollection: TCollection);
begin
  FExtendedValue:= False;
  inherited Create(ACollection);
  FCollection:= ACollection;
end;

procedure TCollectionDataSource.DeleteRecord(ARecordHandle: TcxDataRecordHandle);
begin
  if not Assigned(FCollection) then Exit;
  FCollection.Delete(Integer(ARecordHandle));
  if not Modified then
    FModified := True;
  DataChanged;
end;

destructor TCollectionDataSource.Destroy;
begin

  inherited Destroy;
end;

procedure TCollectionDataSource.DoGetdata;
begin
  if Assigned(FOnGetData) then FOnGetData(Self);
end;

function TCollectionDataSource.GetCollection: TCollection;
begin
  Result:= FCollection;
end;

function TCollectionDataSource.GetRecordCount: Integer;
begin
  if Assigned(FCollection) then
    Result := FCollection.Count
  else
    Result := 0;
end;

procedure TCollectionDataSource.SetCollection(const Value: TCollection);
var
  CreateColumn: Boolean;
begin
  CreateColumn:= (Value = nil) or (FCollection = nil) or (Value.ClassName <> FCollection.ClassName);
  FCollection:= Value;

  if CreateColumn then
  begin
    FBands.Clear;
    FFields.Clear;
    CreateColumnsAllTableView;
  end;

  DataChanged;
end;

procedure TCollectionDataSource.SetOnGetData(const Value: TNotifyEvent);
begin
  FOnGetData := Value;
end;

function TCollectionDataSource.InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle;
begin
  if not Assigned(FCollection) then
  begin
    Result:= TcxDataRecordHandle(-1);
    Exit;
  end;
  FCollection.Insert(Integer(ARecordHandle));
  Result := TcxDataRecordHandle(ARecordHandle);
  if not Modified then FModified := True;
  DataChanged;
end;

function TCollectionDataSource.IsGeralDefined: Boolean;
begin
  Result:= False;
end;

{ TCollectionDataSourceUser }

function TCollectionDataSourceUser.GetFieldValue(Index: Integer; FieldName: String): Variant;
var
  PropInfo: PPropInfo;
  Obj: TObject;
  AItem: TObject;
  FieldName1: String;
  p: Integer;
begin
  if Collection is TWorkEntityList then
    AItem:= TWorkEntityList(Collection)[Index].bf
  else
    AItem:= Collection.Items[Index];

  p:= Pos('.',FieldName);
  if p > 0 then
  begin
    FieldName1:= FieldName;
    Obj:= AItem;
    Repeat
      PropInfo:= TypInfo.GetPropInfo(Obj,Copy(FieldName1,1,p-1));
      Obj:= GetObjectProp(Obj,PropInfo);
      Delete(FieldName1,1,p);
      p:= Pos('.',FieldName1);
    until p = 0;
    PropInfo:= TypInfo.GetPropInfo(Obj,FieldName1);
    AItem:= Obj;
    FieldName:= FieldName1;
  end
  else
  begin
    PropInfo:= TypInfo.GetPropInfo(AItem,FieldName);
  end;

  if PropInfo.PropType^.Kind = tkClass then
  begin
    Obj:= TypInfo.GetObjectProp(AItem,FieldName);
    if Obj is TStringList then
    begin
      Result:= (Obj as TStringList).CommaText;
    end;
  end else
  begin
    Result:= TypInfo.GetPropValue(AItem,FieldName,True);
  end;
end;

function TCollectionDataSourceUser.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var
  AColumnID: Integer;
begin
  if Self.IsUpdating then Exit(null);
  if Integer(ARecordHandle) >= Collection.count then Exit(null);
  AColumnID := GetDefaultItemID(Integer(AItemHandle));
  Result:= GetFieldValue(Integer(ARecordHandle),GetFieldName(AColumnID));
end;

procedure TCollectionDataSourceUser.SetValue(
  ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle;
  const AValue: Variant);
var
  AItem: TCollectionItem;
  AColumnId: Integer;
  AFieldName: String;
  v: Variant;
  PropInfo: PPropInfo;
begin
  AColumnId:= GetDefaultItemID(Integer(AItemHandle));
  AItem:= Collection.Items[Integer(ARecordHandle)];
  AFieldName:= GetFieldName(AColumnId);
  v:= AValue;
  if VarToStr(v) = '' then // Null or Null String To Integer,Float, etc..
  begin
    PropInfo:= GetPropInfo(AItem,AFieldName);
    if not Assigned(PropInfo) then Exit;
    case PropInfo.PropType^.Kind of
      tkInteger: v:= 0;
      tkChar: v:= Char(0);
      tkEnumeration: v:= GetEnumName(PropInfo^.PropType^,0);
      tkFloat: v:= 0.0;
      tkString: v:= '';
      tkSet: v:= '[]';
      tkClass: v:= 0; // nil
      tkMethod: v:= 0; // nil
      tkWChar: v:= WideChar(0);
      tkLString: v:= '';
      tkWString: v:= WideString('');
      tkVariant: v:= Null;
      tkInterface: v:= 0; // nil
      tkInt64: v:= 0;
      // tkUnknown, tkArray , tkRecord e tkDynArray não têm TypeInfo
    end;
  end;
  if AItem.InheritsFrom(TWorkEntity) then
    SetPropValue(TWorkEntity(AItem).bf,AFieldName,v)
  else
    SetPropValue(AItem,AFieldName,v);
  Modified:= True;
  inherited;
end;

procedure TCollectionDataSourceUser.CreateColumns(Comp: TObject);
var
  i: Integer;
  CurrFieldName: String;
  Column: TObject;
  Item: TCollectionItem;
  ItemBf: TObject;
begin
  inherited;
  if Collection = nil then Exit;
  if Fields.Count = 0 then
    LoadAllFields;

  if Collection.ItemClass.InheritsFrom(TWorkEntity) then
    Item:= TWorkEntityClass(Collection.ItemClass).Create(nil,nil)
  else
    Item:= Collection.ItemClass.Create(nil);

  try
    if (IsPublishedProp(Item,_CoreBf)) and (PropIsType(Item,_CoreBf,tkClass)) then
    begin
      ItemBf:= TypInfo.GetObjectProp(Item,_CoreBf);
      Assert(Assigned(ItemBf),'ItemBf is nil');
    end
    else
      ItemBf:= Item;

    for i := 0 to Fields.Count - 1 do
    begin
      CurrFieldName:= GetFieldName(i);
      Column:= CreateColumn(Self,CurrFieldName,ItemBf,Comp,FieldList,False,DisplayFormat,ExtendedValue);
      if Column is TcxGridColumn then
        DoAfterCreateGridColum(CurrFieldName, TcxGridColumn(Column))
      else if Column is TcxTreeListColumn then
        DoAfterCreateTreeListColum(CurrFieldName, TcxTreeListColumn(Column));
    end;
  finally
    Item.Free;
  end;                                              
end;

constructor TCollectionDataSourceUser.Create(ACollection: TCollection; const AFields: string = '');
begin
  inherited Create(ACollection);
  Fields.CommaText := AFields;
end;

destructor TCollectionDataSourceUser.Destroy;
begin

  inherited;
end;

procedure TCollectionDataSourceUser.SetCollection(
  const Value: TCollection);
begin
  inherited SetCollection(Value);
end;

procedure TCollectionDataSourceUser.LoadAllFields;
var
  Count: Integer;
  i: Integer;
  Data: PTypeData;
  Info: PTypeInfo;
  PropList: PPropList;
begin
  Fields.Clear;

  if Collection.ItemClass.InheritsFrom(TWorkEntity) then
    Info:= TWorkEntityClass(Collection.ItemClass).BfClass.ClassInfo
  else
    Info:= Collection.ItemClass.ClassInfo;

  Data:= GetTypeData(Info);
  GetMem(PropList,Data^.PropCount * SizeOf(PPropInfo));
  try
    Count:= GetPropList(Info,tkProperties,PropList,False);
    for i := 0 to (Count - 1) do
    begin
      Fields.Add(String(PropList^[i]^.Name));
    end;
  finally
    FreeMem(PropList,Data^.PropCount * SizeOf(PPropInfo));
  end;
end;

function TCollectionDataSourceUser.DisplayFormat: String;
const
  Dec = 2;
begin
  Result := ',0.' + DupeString('0',Dec);
end;

function CreateColumn(Sender:TObject;FieldName: string; Obj, GridOrTree: TObject;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):Tobject;
var
  PropInfo: PPropInfo;
  ValueTypeClass: TcxValueTypeClass;
  dataTypeUnSuported: Boolean;
  cxGridItem: TcxCustomGridTableItem;
  cxTreeListColumn: TcxTreeListColumn;
  FieldName1:String;
  NamePrefix:String;
  P:Integer;
begin
  Result:= nil;
  NamePrefix:= '';
  if not Assigned(Obj) then Exit;

  if Sender is TCustomBaseCollectionDataSource then
  begin
    NamePrefix:=(Sender as TCustomBaseCollectionDataSource).Name;
  end;
  p:= Pos('.',FieldName);
  if p > 0 then //extended é Obsoleto
  begin
    FieldName1:= FieldName;
    Repeat
      PropInfo:= TypInfo.GetPropInfo(Obj, Copy(FieldName1,1,p-1));
      Obj:= GetObjectProp(Obj,PropInfo);
      Delete(FieldName1,1,p);
      p:= Pos('.',FieldName1);
    until p = 0;
    PropInfo:= TypInfo.GetPropInfo(Obj, FieldName1);
  end
  else
  begin
    if not IsPublishedProp(Obj,FieldName) then
    begin
      raise Exception.CreateFmt('Não existe o campo %s na classe %s', [FieldName,Obj.ClassName]);
    end;
    PropInfo:= TypInfo.GetPropInfo(Obj,FieldName);
    FieldName1:= FieldName;
  end;

  ValueTypeClass:= TcxStringValueType;

  dataTypeUnSuported:= False;
  if PropInfo <> nil then
  begin
    case PropInfo.PropType^.Kind of
      tkInt64,
        tkInteger: ValueTypeClass := TcxIntegerValueType;
      tkWChar,
        tkLString,
        tkWString,
        tkString,
        tkChar: ValueTypeClass := TcxStringValueType;
      tkVariant: ValueTypeClass := TcxVariantValueType;
      tkUnknown,
        tkEnumeration:
          begin
          if AnsiSameText('Boolean', string(PropInfo.PropType^.name)) then
          begin
            ValueTypeClass := TcxBooleanValueType
          end else
            ValueTypeClass := TcxStringValueType;
        end;
      tkFloat:
        begin
          if PropInfo.PropType^.name = 'TDate' then ValueTypeClass := TcxDateTimeValueType
          else if PropInfo.PropType^.name = 'TTime' then ValueTypeClass := TcxDateTimeValueType
          else if PropInfo.PropType^.name = 'TDateTime' then ValueTypeClass := TcxDateTimeValueType
          else ValueTypeClass := TcxFloatValueType;
        end;
      tkClass:
        begin
          if PropInfo.PropType^.name = 'TStringList' then ValueTypeClass := TcxStringValueType
          else  dataTypeUnSuported := False;
        end;
      tkSet:
        begin
          ValueTypeClass := TcxStringValueType
        end;
        tkMethod,
        tkArray,
        tkRecord,
        tkInterface,
        tkDynArray: dataTypeUnSuported:= True;
    end;
  end else
  begin
    dataTypeUnSuported:= True;
  end;

  if dataTypeUnSuported then
     raise Exception.Create('DataType Not Suported: ' + String(PropInfo.PropType^.Name));

  if GridOrTree is TcxCustomGridTableView then
  begin
    if GridOrTree is TcxGridCardView then
      cxGridItem:= TcxGridCardView(GridOrTree).CreateRow //TcxGridCardTableRow
    else //if (GridOrTree is TcxGridTableView) then
      cxGridItem:= TcxGridTableView(GridOrTree).CreateColumn;

    Result:= cxGridItem;

    cxGridItem.Caption:= FieldName1;

    cxGridItem.DataBinding.ValueTypeClass:= ValueTypeClass;
    cxGridItem.DataBinding.Data:= FieldList.Add(FieldName);
    cxGridItem.Name:= TcxCustomGridTableView(GridOrTree).Name + '_' + StringReplace(FieldName,'.','_',[rfReplaceAll, rfIgnoreCase]);

    FormatColumnByValueTypeClass(FieldName,Obj,cxGridItem,ValueTypeClass,ReadOnly,Extended,DisplayFormat);
  end
  else if (GridOrTree is TcxVirtualTreeList) then
  begin
    cxTreeListColumn:= TcxVirtualTreeList(GridOrTree).CreateColumn as TcxTreeListColumn;
    Result:= cxTreeListColumn;

    cxTreeListColumn.Caption.Text:= FieldName;

    cxTreeListColumn.DataBinding.ValueTypeClass:= ValueTypeClass;
    cxTreeListColumn.DataBinding.Data := FieldList.Add(FieldName);
    cxTreeListColumn.Name:= StringReplace(NamePrefix+'_'+FieldName,'.','_',[rfReplaceAll, rfIgnoreCase]);

    FormatColumnByValueTypeClass(FieldName,Obj,cxTreeListColumn,ValueTypeClass,ReadOnly,Extended,DisplayFormat);
  end;
end;

procedure FormatColumnByValueTypeClass(FieldName: String; Obj, GridOrTreeColumn: TObject; ValueTypeClass: TcxValueTypeClass;
  ReadOnly,Extended:Boolean; DisplayFormat: String);
var
  cxGridItem: TcxCustomGridTableItem;
  cxTreeListColumn: TcxTreeListColumn;
  PropInfo: PPropInfo;
  FieldName1: String;
  P: Integer;
begin
  if Obj = nil then Exit;

  p:= Pos('.',FieldName);
  if p > 0 then
  begin
    FieldName1:= FieldName;
    Repeat
      Delete(FieldName1,1,p);
      p:= Pos('.',FieldName1);
    until p = 0;
    PropInfo := TypInfo.GetPropInfo(Obj,FieldName1);
  end else
  begin
    if not IsPublishedProp(Obj,FieldName) then
      raise Exception.CreateFmt('Não existe o campo %s na classe %s', [FieldName,Obj.ClassName]);

    PropInfo := TypInfo.GetPropInfo(Obj,FieldName);
  end;

  if GridOrTreeColumn is TcxCustomGridTableItem then
  begin
    cxGridItem:= GridOrTreeColumn as TcxCustomGridTableItem;

    if ValueTypeClass = TcxIntegerValueType then
    begin
      cxGridItem.PropertiesClass:= TcxCurrencyEditProperties;
      TcxCurrencyEditProperties(cxGridItem.Properties).Alignment.Horz:= taRightJustify;
      TcxCurrencyEditProperties(cxGridItem.Properties).DisplayFormat:= '0';
      TcxCurrencyEditProperties(cxGridItem.Properties).EditFormat:= '';
      TcxCurrencyEditProperties(cxGridItem.Properties).UseThousandSeparator:= True;
      TcxCurrencyEditProperties(cxGridItem.Properties).UseDisplayFormatWhenEditing:= False;
      TcxCurrencyEditProperties(cxGridItem.Properties).AssignedValues.DisplayFormat:= True;
      TcxCurrencyEditProperties(cxGridItem.Properties).AssignedValues.EditFormat:= True;
    end;

    if ValueTypeClass = TcxFloatValueType then
    begin
      cxGridItem.PropertiesClass := TcxCurrencyEditProperties;
      TcxCurrencyEditProperties(cxGridItem.Properties).Alignment.Horz := taRightJustify;
      TcxCurrencyEditProperties(cxGridItem.Properties).DisplayFormat := DisplayFormat;
      TcxCurrencyEditProperties(cxGridItem.Properties).EditFormat := '';
      TcxCurrencyEditProperties(cxGridItem.Properties).UseThousandSeparator := true;
      TcxCurrencyEditProperties(cxGridItem.Properties).UseDisplayFormatWhenEditing := false;
      TcxCurrencyEditProperties(cxGridItem.Properties).AssignedValues.DisplayFormat := True;
      TcxCurrencyEditProperties(cxGridItem.Properties).AssignedValues.EditFormat := true;
    end;

    if ValueTypeClass = TcxBooleanValueType then
    begin
      cxGridItem.PropertiesClass := TcxCheckBoxProperties;
    end;

    if PropInfo <> nil then
    begin
      if PropInfo.PropType^.Name = 'TTime' then
      begin
        cxGridItem.PropertiesClass:= TcxTimeEditProperties;
      end;

      if PropInfo.PropType^.Name = 'TDate' then
      begin
        cxGridItem.PropertiesClass:= TcxDateEditProperties;
      end;

      if PropInfo.PropType^.Name = 'TDateTime' then
      begin
        cxGridItem.PropertiesClass:= TcxTimeEditProperties;
        TcxTimeEditProperties(cxGridItem.Properties).ShowDate:=True;
      end;

      //Verificar se é ReadOnly
      if (not Assigned(PropInfo.SetProc)) or ReadOnly then
      begin
        cxGridItem.Options.Editing:= False;
      end;
    end;
  end
  else if (GridOrTreeColumn is TcxTreeListColumn) then
  begin
    cxTreeListColumn:= (GridOrTreeColumn as TcxTreeListColumn);

    if ValueTypeClass = TcxIntegerValueType then
    begin
      cxTreeListColumn.PropertiesClass := TcxCurrencyEditProperties;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).Alignment.Horz := taRightJustify;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).DisplayFormat := '0';
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).EditFormat := '';
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).UseThousandSeparator := true;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).UseDisplayFormatWhenEditing := false;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).AssignedValues.DisplayFormat := True;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).AssignedValues.EditFormat := true;
    end;

    if ValueTypeClass = TcxFloatValueType then
    begin
      cxTreeListColumn.PropertiesClass := TcxCurrencyEditProperties;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).Alignment.Horz := taRightJustify;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).DisplayFormat := DisplayFormat;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).EditFormat := '';
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).UseThousandSeparator := true;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).UseDisplayFormatWhenEditing := false;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).AssignedValues.DisplayFormat := True;
      TcxCurrencyEditProperties(cxTreeListColumn.Properties).AssignedValues.EditFormat := true;
    end;

    if ValueTypeClass = TcxBooleanValueType then
    begin
      cxTreeListColumn.PropertiesClass := TcxCheckBoxProperties;
    end;

    if PropInfo <> nil then
    begin
      if PropInfo.PropType^.name = 'TTime' then
      begin
        cxTreeListColumn.PropertiesClass:= TcxTimeEditProperties;
      end;

      if PropInfo.PropType^.name = 'TDate' then
      begin
        cxTreeListColumn.PropertiesClass:= TcxDateEditProperties;
      end;

      if PropInfo.PropType^.name = 'TDateTime' then
      begin
        cxTreeListColumn.PropertiesClass:= TcxTimeEditProperties;
        TcxTimeEditProperties(cxTreeListColumn.Properties).ShowDate:= True;
      end;

      //Verificar se é ReadOnly
      if (not Assigned(PropInfo.SetProc)) or ReadOnly then
      begin
        cxTreeListColumn.Options.Editing:= False;
      end;
    end;
  end;
end;

function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Grid: TcxGridTableView;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxGridColumn;
begin
  Result:= TcxGridColumn(CreateColumn(Sender,FieldName,Obj,Grid,FieldList,ReadOnly,DisplayFormat,Extended));
end;

function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Grid: TcxGridCardView;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxGridCardViewRow; overload;
begin
  result:= TcxGridCardViewRow(CreateColumn(Sender,FieldName,Obj,Grid,FieldList,ReadOnly,DisplayFormat,Extended));
end;

function CreateColumn(Sender:TObject;FieldName: string; Obj:TObject; Tree: TcxVirtualTreeList;FieldList:TWorkFieldList;ReadOnly:Boolean;DisplayFormat:String;Extended:Boolean):TcxTreeListColumn;
begin
  Result:= TcxTreeListColumn(CreateColumn(Sender,FieldName,Obj,Tree,FieldList,ReadOnly,DisplayFormat,Extended));
end;

{ TCollectionTreeDataSourceUser }

function TCollectionTreeDataSourceUser.AppendRecord: TcxDataRecordHandle;
begin
  Result:= inherited AppendRecord;
end;

procedure TCollectionTreeDataSourceUser.AssignControl(Control: TObject; ABandsInFieldList: Boolean);
begin
  inherited AssignControl(Control);

  if Control is TcxVirtualTreeList then
  begin
    TcxVirtualTreeList(Control).DataController.CustomDataSource := self;
    TcxVirtualTreeList(Control).BeginUpdate;
    try
      if not ABandsInFieldList then
        CreateColumns(Control);
    finally
      TcxVirtualTreeList(Control).EndUpdate;
    end;
  end;
end;

procedure TCollectionTreeDataSourceUser.AssignTreeView(AVirtualTreeList: TcxVirtualTreeList; ABandsInFieldList: Boolean);
begin
  AssignControl(AVirtualTreeList,ABandsInFieldList);
end;

constructor TCollectionTreeDataSourceUser.Create(ACollection: TCollection; AKeyField, AParentField: string; const AFields: string);
begin
  inherited Create(ACollection,AFields);
  FKeyField:= AKeyField;
  FParentField:= AParentField;
end;

destructor TCollectionTreeDataSourceUser.Destroy;
begin

  inherited;
end;

function TCollectionTreeDataSourceUser.GetColumnByFieldName(ATree : TcxVirtualTreeList;FieldName: string): TcxTreeListColumn;
var
  i: Integer;
begin
  Result:= nil;
  for i := 0 to ATree.ColumnCount - 1 do
    if SameText(TWorkField(ATree.Columns[i].DataBinding.Data).FieldName,FieldName) then
      Exit(ATree.Columns[i]);
end;

function TCollectionTreeDataSourceUser.GetParentRecordHandle(
  ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle;
var
  RecordValue,ParentValue: Variant;
  i: Integer;
begin
  Result:= cxNullRecordHandle;
  if Integer(ARecordHandle) < Collection.Count then
  begin
    if Collection is TWorkEntityList then
      ParentValue:= TypInfo.GetPropValue(TypInfo.GetObjectProp(Collection.Items[Integer(ARecordHandle)],_CoreBf),FParentField)
    else
      ParentValue:= TypInfo.GetPropValue(Collection.Items[Integer(ARecordHandle)],FParentField);

    if VarToStrDef(ParentValue,'') = '' then Exit;
    for i := 0 to Collection.Count - 1 do
    begin
      if Collection is TWorkEntityList then
        RecordValue:= TypInfo.GetPropValue(TypInfo.GetObjectProp(Collection.Items[i],_CoreBf),FKeyField)
      else
        RecordValue:= TypInfo.GetPropValue(Collection.Items[i],FKeyField);

      if VarCompareValue(RecordValue,ParentValue) = vrEqual then
        Exit(TcxDataRecordHandle(i));
    end;
  end;
end;

end.
