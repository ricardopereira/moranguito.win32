unit WorkEngine;

interface

uses
  SysUtils, Classes, WorkClasses, WorkEntityClasses;

const
  _CorePoint = 'data.db';

type
  TCoreEntityItem = class;
  TCoreEntityList = class;

  TCoreEngine = class(TCustomPersistent)
  private
    FCoreEntityList: TCoreEntityList;
  public
    constructor Create;
    destructor Destroy; override;

    property CoreEntityList: TCoreEntityList read FCoreEntityList;
  end;

  TCoreEntityItem = class(TCustomCollectionItem)
  private
    FEntityName: string;
    FEntityClass: TWorkEntityClass;
    function GetPrimaryFieldKey: string;
    property EntityClass: TWorkEntityClass read FEntityClass write FEntityClass;
  public
    function GetFieldsList(AFieldsList: TStringList): boolean;
    function GetIndexsList(AIndexsList: TStringList): boolean;
  published
    property EntityName: string read FEntityName write FEntityName;
    property PrimaryFieldKey: string read GetPrimaryFieldKey;
  end;

  TCoreEntityList = class(TCustomCollection)
  private
    function GetItem(Index: integer): TCoreEntityItem;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TCoreEntityItem; reintroduce;
    property Items[Index: integer]: TCoreEntityItem read GetItem; default;

    procedure Register(AEntityClass: TWorkEntityClass);
  end;

  procedure RegisterEntity(AEntityClass: TWorkEntityClass);

var
  CoreEngine: TCoreEngine;

implementation

uses
  TypInfo, WorkTypes;

procedure RegisterEntity(AEntityClass: TWorkEntityClass);
begin
  CoreEngine.CoreEntityList.Register(AEntityClass);
end;

{ TCoreEngine }

constructor TCoreEngine.Create;
begin
  inherited;
  FCoreEntityList:= TCoreEntityList.Create;
end;

destructor TCoreEngine.Destroy;
begin
  FreeAndNil(FCoreEntityList);
  inherited;
end;

{ TCoreEntityItem }

function TCoreEntityItem.GetFieldsList(AFieldsList: TStringList): boolean;
begin
  Result:= EntityClass.GetFieldsList(AFieldsList);
end;

function TCoreEntityItem.GetIndexsList(AIndexsList: TStringList): boolean;
begin
  Result:= EntityClass.GetIndexsList(AIndexsList);
end;

function TCoreEntityItem.GetPrimaryFieldKey: string;
begin
  Result:= EntityClass.GetEntityPrimaryKey;
end;

{ TCoreEntityList }

constructor TCoreEntityList.Create;
begin
  inherited Create(TCoreEntityItem);

end;

destructor TCoreEntityList.Destroy;
begin

  inherited;
end;

function TCoreEntityList.Add: TCoreEntityItem;
begin
  result := TCoreEntityItem(inherited Add);
end;

function TCoreEntityList.GetItem(Index: integer): TCoreEntityItem;
begin
  if Index < 0 then Exit(nil);
  result := TCoreEntityItem(inherited GetItem(Index));
end;

procedure TCoreEntityList.Register(AEntityClass: TWorkEntityClass);
begin
  with Add do
  begin
    EntityName := AEntityClass.GetEntityName;
    EntityClass := AEntityClass;
  end;
end;

initialization
  CoreEngine:= TCoreEngine.Create;
finalization
  FreeAndNil(CoreEngine);
end.
