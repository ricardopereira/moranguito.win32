unit WAlimentos;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities, WTiposAlimento,
  WorkTypes;

type
  TWAlimentos = class;
  TWAlimentosList = class;

  TWAlimentosBf = class(TWorkEntityBf)
  private
    FAlimentoID: String;
    FNome: String;
    FTipoAlimentoID: Integer;
    function GetTipoAlimentoNome: String;
  protected
    function Entity: TWAlimentos;
  public
  published
    property AlimentoID: String read FAlimentoID write FAlimentoID;
    property Nome: String read FNome write FNome;
    property TipoAlimentoID: Integer read FTipoAlimentoID write FTipoAlimentoID;
    //Virtual
    property TipoAlimentoNome: String read GetTipoAlimentoNome;
  end;

  TWAlimentos = class(TWorkEntity)
  private
    FTiposAlimento: TWTiposAlimento;
    function GetBf: TWAlimentosBf;
    function GetTiposAlimento: TWTiposAlimento;
  protected
    function List: TWAlimentosList;
  public
    destructor Destroy; override;
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(AAlimentoID: String; const ALoadBf: Boolean=True): Boolean;
    function ExistNome(ANome: String; const ALoadBf: Boolean=True): Boolean;
    procedure Validate; override;
    function HasRelations(ARaise: Boolean=True): Boolean; override;
    procedure CheckRelations(AAlimentoID: String);
    procedure Save; override;
    procedure Delete(AAlimentoID: String); reintroduce; overload;
  published
    property bf: TWAlimentosBf read GetBf;
    property TiposAlimento: TWTiposAlimento read GetTiposAlimento;
  end;

  TWAlimentosList = class(TWorkEntityList)
  private
    FInternalTiposAlimento: TWTiposAlimento;
    function GetItem(Index: Integer): TWAlimentos;
  protected
    function InternalTiposAlimento: TWTiposAlimento;
  public
    destructor Destroy; override;
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWAlimentos;
    property Items[Index: Integer]: TWAlimentos read GetItem; default;
  end;

implementation

uses
  WAnalise;

{ TWAlimentosBf }

function TWAlimentosBf.Entity: TWAlimentos;
begin
  Result:= Owner as TWAlimentos;
end;

function TWAlimentosBf.GetTipoAlimentoNome: String;
begin
  Result:= Trim(Entity.TiposAlimento.bf.Nome);
end;

{ TWAlimentos }

destructor TWAlimentos.Destroy;
begin
  FreeAndNil(FTiposAlimento);
  inherited;
end;

class function TWAlimentos.BfClass: TWorkEntityBfClass;
begin
  Result:= TWAlimentosBf;
end;

function TWAlimentos.GetBf: TWAlimentosBf;
begin
  Result:= inherited GetBf as TWAlimentosBf;
end;

function TWAlimentos.List: TWAlimentosList;
begin
  Result:= Collection as TWAlimentosList;
end;

class function TWAlimentos.GetEntityName: string;
begin
  Result:= 'Alimentos';
end;

class function TWAlimentos.GetEntityPrimaryKey: string;
begin
  Result:= 'AlimentoID';
end;

class function TWAlimentos.GetEntityIndexs: string;
begin
  Result:= 'AlimentoID';
end;

function TWAlimentos.HasRelations(ARaise: Boolean): Boolean;
begin
  Result:= inherited HasRelations(False); //ToDo
  if ARaise then
    CheckRelations(bf.AlimentoID);
end;

procedure TWAlimentos.CheckRelations(AAlimentoID: String);
var
  Res: Boolean;
begin
  with TWAnalise.Create(nil,Session) do
  try
    Res:= ExistRecord(Format(SQLWhere+'AlimentoID=%s',['Analise',QuotedStr(AAlimentoID)]),False);
    if Res then
      raise EWorkEntity.CreateFmt('O alimento "%s" está a ser utilizado na Introdução de Alimentos.',[Self.bf.Nome]);
  finally
    Free;
  end;
end;

function TWAlimentos.GetTiposAlimento: TWTiposAlimento;
begin
  if List = nil then
  begin
    if not Assigned(FTiposAlimento) then
      FTiposAlimento:= TWTiposAlimento.Create(nil,Session);
    Result:= FTiposAlimento;
  end
  else
  begin
    Result:= List.InternalTiposAlimento;
  end;
  if bf.TipoAlimentoID <> Result.bf.TipoAlimentoID then
    Result.Exist(bf.TipoAlimentoID);
end;

function TWAlimentos.Exist(AAlimentoID: String; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,AAlimentoID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

function TWAlimentos.ExistNome(ANome: String; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(Format(SQLWhere+'Nome=%s',[GetEntityName,
    QuotedStr(ANome)]),True);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

procedure TWAlimentos.Save;
begin
  inherited;
  if Exist(bf.AlimentoID,False) then
    Update
  else
    Insert;
end;

procedure TWAlimentos.Validate;
begin
  inherited;
  if ExistNome(bf.Nome,False) then
    raise EWorkEntity.CreateFmt('O alimento "%s" já existe.',[bf.Nome]);
end;

procedure TWAlimentos.Delete(AAlimentoID: String);
begin
  CheckRelations(AAlimentoID);
  inherited Delete(AAlimentoID);
end;

{ TWAlimentosList }

destructor TWAlimentosList.Destroy;
begin
  FreeAndNil(FInternalTiposAlimento);
  inherited;
end;

function TWAlimentosList.Add: TWAlimentos;
begin
  Result:= inherited Add as TWAlimentos;
end;

class function TWAlimentosList.EntityClass: TWorkEntityClass;
begin
  Result:= TWAlimentos;
end;

function TWAlimentosList.GetItem(Index: Integer): TWAlimentos;
begin
  Result:= inherited GetItem(Index) as TWAlimentos;
end;

function TWAlimentosList.InternalTiposAlimento: TWTiposAlimento;
begin
  if not Assigned(FInternalTiposAlimento) then
    FInternalTiposAlimento:= TWTiposAlimento.Create(nil,Session);
  Result:= FInternalTiposAlimento;
end;

initialization
  RegisterEntity(TWAlimentos);
end.
