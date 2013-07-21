unit WEstruct;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities;

type
  TWEstructNodeType = (ntFolder, ntItem);

type
  TWEstructBf = class(TWorkEntityBf)
  private
    FParentNodeId: String;
    FNodeId: String;
    FName: String;
  public
  published
    property ParentNodeId: String read FParentNodeId write FParentNodeId;
    property NodeId: String read FNodeId write FNodeId;
    property Name: String read FName write FName;
  end;

  TWEstruct = class(TWorkEntity)
  private
  protected
    function GetBf: TWEstructBf;
  public
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(ANodeId: String; const ALoadBf: boolean=true): boolean;
    procedure Save; override;
    procedure Delete(ANodeId: String); reintroduce; overload;
    procedure Delete(AChilds: Boolean=True); reintroduce; overload;
    procedure DeleteChilds(ANodeId: String);
  published
    property bf: TWEstructBf read GetBf;
  end;

  TWEstructList = class(TWorkEntityList)
  private
    function GetItem(Index: Integer): TWEstruct;
  public
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWEstruct;
    procedure DeleteChilds(ANodeId: String);
    property Items[Index: Integer]: TWEstruct read GetItem; default;
  end;

implementation

{ TWEstructBf }

{ TWEstruct }

class function TWEstruct.BfClass: TWorkEntityBfClass;
begin
  Result := TWEstructBf;
end;

function TWEstruct.GetBf: TWEstructBf;
begin
  Result:= TWEstructBf(inherited GetBf);
end;

class function TWEstruct.GetEntityName: string;
begin
  Result:= 'Estruct';
end;

class function TWEstruct.GetEntityPrimaryKey: string;
begin
  Result:= 'NodeId';
end;

class function TWEstruct.GetEntityIndexs: string;
begin
  Result:= 'NodeId';
end;

function TWEstruct.Exist(ANodeId: string; const ALoadBf: boolean): boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,ANodeId);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

procedure TWEstruct.Save;
begin
  inherited;
  if Exist(bf.NodeId,false) then Update
  else Insert;
end;

procedure TWEstruct.Delete(ANodeId: String);
begin
  inherited Delete(ANodeId);
end;

procedure TWEstruct.Delete(AChilds: Boolean);
var
  ID: String;
begin
  ID:= bf.NodeId;
  if Exist(ID,false) then
  begin
    Delete(ID);
    if AChilds then
      DeleteChilds(ID);
  end;
end;

procedure TWEstruct.DeleteChilds(ANodeId: String);
var
  DelSql: String;
begin
  //ToDo
  DelSql:= Format('DELETE FROM %s WHERE %s=%s OR %s=%s',[GetEntityName,GetEntityPrimaryKey,QuotedStr(ANodeId),'ParentNodeId',QuotedStr(ANodeId)]);
  Session.ExecSQL(DelSql);
end;

{ TWEstructList }

function TWEstructList.Add: TWEstruct;
begin
  Result:= TWEstruct(inherited Add);
end;

procedure TWEstructList.DeleteChilds(ANodeId: String);
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    if SameString(Items[i].bf.ParentNodeId,ANodeId) then
    begin
      //ToDo
      //DeleteChilds(Items[i].bf.NodeId);
      Delete(i);
    end;
  end;
end;

class function TWEstructList.EntityClass: TWorkEntityClass;
begin
  Result:= TWEstruct;
end;

function TWEstructList.GetItem(Index: Integer): TWEstruct;
begin
  Result:= TWEstruct(inherited GetItem(Index));
end;

initialization
  RegisterEntity(TWEstruct);
end.
