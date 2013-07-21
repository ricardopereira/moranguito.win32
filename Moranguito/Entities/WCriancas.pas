unit WCriancas;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities, WorkTypes,
  WAlimentos;

type
  TWCriancas = class;
  TWCriancasList = class;

  TWCriancasBf = class(TWorkEntityBf)
  private
    FCriancaID: String;
    FNome: String;
    FIdade: Integer;
    function GetAlimentosStr: String;
  public
     function Entity: TWCriancas;
  published
    property CriancaID: String read FCriancaID write FCriancaID;
    property Nome: String read FNome write FNome;
    property Idade: Integer read FIdade write FIdade;
    property AlimentosStr: String read GetAlimentosStr;
  end;

  TWCriancas = class(TWorkEntity)
  private
    FAlimentosList: TWAlimentosList;
    function GetBf: TWCriancasBf;
    function GetAlimentosList: TWAlimentosList;
  protected
    function List: TWCriancasList;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(ACriancaID: String; const ALoadBf: Boolean=True): Boolean;
    function ExistNome(ANome: String; const ALoadBf: Boolean=True): Boolean;
    procedure Validate; override;
    function HasRelations(ARaise: Boolean=True): Boolean; override;
    procedure CheckRelations(ACriancaID: String);
    procedure Save; override;
    procedure Delete(ACriancaID: String); reintroduce; overload;

    property AlimentosList: TWAlimentosList read GetAlimentosList;
  published
    property bf: TWCriancasBf read GetBf;
  end;

  TWCriancasList = class(TWorkEntityList)
  private
    function GetItem(Index: Integer): TWCriancas;
  public
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWCriancas;
    property Items[Index: Integer]: TWCriancas read GetItem; default;
  end;

implementation

uses
  WAnalise;

{ TWCriancasBf }

function TWCriancasBf.Entity: TWCriancas;
begin
  Result:= Owner as TWCriancas;
end;

function TWCriancasBf.GetAlimentosStr: String;
var
  i: Integer;
begin
  Result:= '';
  for i := 0 to Entity.AlimentosList.Count - 1 do
  begin
    Result:= Result + Entity.AlimentosList[i].bf.Nome;
    if i <> Entity.AlimentosList.Count - 1 then
      Result:= Result + ', ';
  end;
end;

{ TWCriancas }

destructor TWCriancas.Destroy;
begin
  FreeAndNil(FAlimentosList);
  inherited;
end;

procedure TWCriancas.Assign(Source: TPersistent);
begin
  if not Source.InheritsFrom(TWCriancas) then
  begin
    inherited;
    Exit;
  end;
  bf.CriancaID:= TWCriancas(Source).bf.CriancaID;
  bf.Nome:= TWCriancas(Source).bf.Nome;
  bf.Idade:= TWCriancas(Source).bf.Idade;
end;

class function TWCriancas.BfClass: TWorkEntityBfClass;
begin
  Result:= TWCriancasBf;
end;

function TWCriancas.GetBf: TWCriancasBf;
begin
  Result:= inherited GetBf as TWCriancasBf;
end;

function TWCriancas.List: TWCriancasList;
begin
  Result:= Collection as TWCriancasList;
end;

function TWCriancas.GetAlimentosList: TWAlimentosList;
begin
  if not Assigned(FAlimentosList) then
    FAlimentosList:= TWAlimentosList.Create(Session);
  Result:= FAlimentosList;
end;

class function TWCriancas.GetEntityName: string;
begin
  Result:= 'Criancas';
end;

class function TWCriancas.GetEntityPrimaryKey: string;
begin
  Result:= 'CriancaID';
end;

class function TWCriancas.GetEntityIndexs: string;
begin
  Result:= 'CriancaID';
end;

function TWCriancas.HasRelations(ARaise: Boolean): Boolean;
begin
  Result:= inherited HasRelations(False); //ToDo
  if ARaise then
    CheckRelations(bf.CriancaID);
end;

procedure TWCriancas.CheckRelations(ACriancaID: String);
var
  Res: Boolean;
begin
  with TWAnalise.Create(nil,Session) do
  try
    //ToDo: List of Tables
    Res:= ExistRecord(Format(SQLWhere+'CriancaID=%s',['Analise',QuotedStr(ACriancaID)]),False);
    if Res then
      raise EWorkEntity.CreateFmt('O "%s" está a ser utilizado na Introdução de Alimentos.',[Self.bf.Nome]);
  finally
    Free;
  end;
end;

function TWCriancas.Exist(ACriancaID: String; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,ACriancaID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

function TWCriancas.ExistNome(ANome: String; const ALoadBf: Boolean): Boolean;
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

procedure TWCriancas.Save;
begin
  inherited;
  if Exist(bf.CriancaID,False) then
    Update
  else
    Insert;
end;

procedure TWCriancas.Validate;
begin
  inherited;
  if Exist(bf.Nome,False) then
    raise EWorkEntity.CreateFmt('A criança "%s" já existe.',[bf.Nome]);
end;

procedure TWCriancas.Delete(ACriancaID: String);
begin
  CheckRelations(ACriancaID);
  inherited Delete(ACriancaID);
end;

{ TWCriancasList }

function TWCriancasList.Add: TWCriancas;
begin
  Result:= inherited Add as TWCriancas;
end;

class function TWCriancasList.EntityClass: TWorkEntityClass;
begin
  Result:= TWCriancas;
end;

function TWCriancasList.GetItem(Index: Integer): TWCriancas;
begin
  Result:= inherited GetItem(Index) as TWCriancas;
end;

initialization
  RegisterEntity(TWCriancas);
end.
