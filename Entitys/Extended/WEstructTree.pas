unit WEstructTree;

interface

uses
  WEstruct, CollectionToCxGrid,
  SysUtils, Classes, WorkSession, WorkEntityClasses;

type
  TObjWEstructTree = class (TCoreController)
  private
    FList: TWEstructList;
    FDataSource: TCollectionTreeDataSourceUser;
  public
    constructor Create(AOwner: TPersistent; AList: TWEstructList; ADS: TCollectionTreeDataSourceUser); reintroduce;
    function CreateNewNode(AIndex: integer; ANodeType: TWEstructNodeType; AName: string): string;
    procedure DeleteNode(AIndex: integer);

    property List: TWEstructList read FList;
    property DataSource: TCollectionTreeDataSourceUser read FDataSource;
  end;

implementation

uses
  Utilities;

{ TObjWEstructTree }

constructor TObjWEstructTree.Create(AOwner: TPersistent; AList: TWEstructList; ADS: TCollectionTreeDataSourceUser);
begin
  Assert(AList<>nil,'List is nil');
  Assert(ADS<>nil,'DS is nil');
  inherited Create(AOwner, AList.Session);
  FList:= AList;
  FDataSource:= ADS;
end;

function TObjWEstructTree.CreateNewNode(AIndex: integer; ANodeType: TWEstructNodeType; AName: string): string;
var
  ParentNodeId: string;
  NodeId: string;
begin
  result := '';
  if Trim(AName)='' then exit;

  NodeId := NewGUIDStr;
  ParentNodeId := '';
  if (AIndex>=0) then
    ParentNodeId := List[AIndex].bf.NodeId;

  with List.Add do
  begin
    bf.NodeId := NodeId;
    bf.ParentNodeId := ParentNodeId;
    bf.Name := Trim(AName);
    Save;
  end;
  result := NodeId;
  DataSource.DataChanged;
end;

procedure TObjWEstructTree.DeleteNode(AIndex: integer);
var
  ID: string;
begin
  if AIndex<0 then exit;
  DataSource.BeginUpdate;
  try
    ID := List[AIndex].bf.NodeId;
    List[AIndex].Delete;
    List.DeleteChilds(ID);
    List.Delete(AIndex);
  finally
    DataSource.EndUpdate;
  end;
  DataSource.DataChanged;
end;

end.
