unit WorkClasses;

interface

uses
  Classes, Contnrs, Controls, SysUtils;

type
  TCustomCollectionItem = class;
  TCustomCollectionItemClass = class of TCustomCollectionItem;
  TCustomCollection = class;
  TCustomCollectionClass = class of TCustomCollection;

  TCustomObjectList = class(TObjectList,IInterface)
  private
    FOwnerInterface: IUnknown;
  protected
    { IUnknown }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
  end;

  ICustomInterface = interface
  ['{98E6FD87-77A8-431C-B656-9B99E662160C}']
  end;

  TCustomPersistent = class(TInterfacedPersistent,ICustomInterface)
  private
  protected
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TCustomCollectionItem = class(TCollectionItem,ICustomInterface)
  private
    FOwnerInterface: IUnknown;
  protected
    { IUnknown }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function GetIndex: Integer;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  end;

  TCustomCollection = class(TCollection,ICustomInterface)
  private
    FOwnerInterface: IUnknown;
    function GetIsUpdating: Boolean;
  protected
    { IUnknown }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function GetCount: Integer;
  public
    constructor Create(ItemClass: TCollectionItemClass);
    destructor Destroy; override;
    property IsUpdating:Boolean Read GetIsUpdating;
    procedure AfterConstruction; override;
  end;

implementation

{ TCustomObjectList }

function TCustomObjectList._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function TCustomObjectList._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

function TCustomObjectList.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

{ TCustomPersistent }

constructor TCustomPersistent.Create;
begin

end;

destructor TCustomPersistent.Destroy;
begin
  inherited;

end;

{ TCustomCollectionItem }

constructor TCustomCollectionItem.Create(Collection: TCollection);
begin
  inherited;

end;

destructor TCustomCollectionItem.Destroy;
begin

  inherited;
end;

function TCustomCollectionItem.GetIndex: Integer;
begin
  result := (inherited Index);
end;

function TCustomCollectionItem._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function TCustomCollectionItem._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

function TCustomCollectionItem.QueryInterface(const IID: TGUID;
  out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TCustomCollectionItem.AfterConstruction;
begin
  inherited;
  if GetOwner <> nil then
    GetOwner.GetInterface(IUnknown, FOwnerInterface);
end;

{ TCustomCollection }

procedure TCustomCollection.AfterConstruction;
begin
  inherited;
  if GetOwner <> nil then
    GetOwner.GetInterface(IUnknown, FOwnerInterface);
end;

constructor TCustomCollection.Create(ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
end;

destructor TCustomCollection.Destroy;
begin

  inherited;
end;

function TCustomCollection.GetCount: Integer;
begin
  result := (inherited Count);
end;

function TCustomCollection.GetIsUpdating: Boolean;
begin
  Result:=(UpdateCount<>0);
end;

function TCustomCollection._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function TCustomCollection._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

function TCustomCollection.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

end.
