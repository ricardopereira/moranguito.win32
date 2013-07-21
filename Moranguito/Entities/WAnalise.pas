unit WAnalise;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities, WorkTypes,
  WAlimentos, WCriancas;

type
  TWAnalise = class;
  TWAnaliseList = class;

  TWAnaliseBf = class(TWorkEntityBf)
  private
    FAnaliseID: String;
    FCriancaID: String;
    FAlimentoID: String;
    function GetAlimentoNome: String;
    function GetCriancaNome: String;
  protected
    function Entity: TWAnalise;
  public
  published
    property AnaliseID: String read FAnaliseID write FAnaliseID;
    property CriancaID: String read FCriancaID write FCriancaID;
    property AlimentoID: String read FAlimentoID write FAlimentoID;
    //Virtual
    property CriancaNome: String read GetCriancaNome;
    property AlimentoNome: String read GetAlimentoNome;
  end;

  TWAnalise = class(TWorkEntity)
  private
    FAlimento: TWAlimentos;
    FCrianca: TWCriancas;
    function GetBf: TWAnaliseBf;
    function GetAlimento: TWAlimentos;
    function GetCrianca: TWCriancas;
  protected
    function List: TWAnaliseList;
  public
    destructor Destroy; override;

    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(AAnaliseID: String; const ALoadBf: Boolean=True): Boolean; overload;
    function Exist(AAlimentoID,ACriancaID: String; const ALoadBf: Boolean=True): Boolean; overload;
    procedure Save; override;
    procedure Delete; reintroduce;
    procedure DeleteWithAlimento(AAlimentoID: String);
    procedure DeleteWithCrianca(ACriancaID: String);
  published
    property bf: TWAnaliseBf read GetBf;
    property Crianca: TWCriancas read GetCrianca;
    property Alimento: TWAlimentos read GetAlimento;
  end;

  TWAnaliseList = class(TWorkEntityList)
  private
    FInternalCrianca: TWCriancas;
    FInternalAlimento: TWAlimentos;
    function GetItem(Index: Integer): TWAnalise;
  protected
    function InternalCrianca: TWCriancas;
    function InternalAlimento: TWAlimentos;
  public
    destructor Destroy; override;
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWAnalise;
    function IndexOfAlimento(AAlimentoID: String): Integer;
    function IndexOfCrianca(ACriancaID: String): Integer;
    procedure GetByAlimento(AAlimentoID: String; AClear: Boolean=True);
    procedure GetByAlimentos(AAlimentosList: TStringList; AClear: Boolean=True);
    procedure GetByCrianca(ACriancaID: String; AClear: Boolean=True);
    property Items[Index: Integer]: TWAnalise read GetItem; default;
  end;

implementation

{ TWAnaliseBf }

function TWAnaliseBf.Entity: TWAnalise;
begin
  Result:= Owner  as TWAnalise;
end;

function TWAnaliseBf.GetAlimentoNome: String;
begin
  Result:= Trim(Entity.Alimento.bf.Nome);
end;

function TWAnaliseBf.GetCriancaNome: String;
begin
  Result:= Trim(Entity.Crianca.bf.Nome);
end;

{ TWAnalise }

destructor TWAnalise.Destroy;
begin
   FreeAndNil(FAlimento);
   FreeAndNil(FCrianca);
  inherited;
end;

class function TWAnalise.BfClass: TWorkEntityBfClass;
begin
  Result:= TWAnaliseBf;
end;

function TWAnalise.GetBf: TWAnaliseBf;
begin
  Result:= inherited GetBf as TWAnaliseBf;
end;

function TWAnalise.GetAlimento: TWAlimentos;
begin
  if List = nil then
  begin
    if not Assigned(FAlimento) then
      FAlimento:= TWAlimentos.Create(nil,Session);
    Result:= FAlimento;
  end
  else
  begin
    Result:= List.InternalAlimento;
  end;
  if bf.AlimentoID <> Result.bf.AlimentoID then
    Result.Exist(bf.AlimentoID);
end;

function TWAnalise.GetCrianca: TWCriancas;
begin
  if List = nil then
  begin
    if not Assigned(FCrianca) then
      FCrianca:= TWCriancas.Create(nil,Session);
    Result:= FCrianca;
  end
  else
  begin
    Result:= List.InternalCrianca;
  end;
  if bf.CriancaID <> Result.bf.CriancaID then
    Result.Exist(bf.CriancaID);
end;

class function TWAnalise.GetEntityName: string;
begin
  Result:= 'Analise';
end;

class function TWAnalise.GetEntityPrimaryKey: string;
begin
  Result:= 'AnaliseID';
end;

class function TWAnalise.GetEntityIndexs: string;
begin
  Result:= 'AnaliseID';
end;

function TWAnalise.List: TWAnaliseList;
begin
  Result:= Collection as TWAnaliseList;
end;

function TWAnalise.Exist(AAnaliseID: String; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,AAnaliseID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

function TWAnalise.Exist(AAlimentoID, ACriancaID: String;
  const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(Format(SQLWhere+'AlimentoID=%s AND CriancaID=%s',[GetEntityName,
    QuotedStr(AAlimentoID),QuotedStr(ACriancaID)]),True);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

procedure TWAnalise.Save;
begin
  inherited;
  if Exist(bf.AnaliseID,False) then
    Update
  else
    Insert;
end;

procedure TWAnalise.Delete;
begin
  inherited Delete(bf.AnaliseID);
end;

procedure TWAnalise.DeleteWithAlimento(AAlimentoID: String);
var
  DeleteSql: String;
begin
  DeleteSql:= Format(SQLDeleteWhere+'AlimentoID=%s',[GetEntityName,QuotedStr(AAlimentoID)]);
  Session.ExecSQL(DeleteSql);
end;

procedure TWAnalise.DeleteWithCrianca(ACriancaID: String);
var
  DeleteSql: String;
begin
  DeleteSql:= Format(SQLDeleteWhere+'CriancaID=%s',[GetEntityName,QuotedStr(ACriancaID)]);
  Session.ExecSQL(DeleteSql);
end;

{ TWAnaliseList }

destructor TWAnaliseList.Destroy;
begin
  FreeAndNil(FInternalCrianca);
  FreeAndNil(FInternalAlimento);
  inherited;
end;

function TWAnaliseList.Add: TWAnalise;
begin
  Result:= inherited Add as TWAnalise;
end;

class function TWAnaliseList.EntityClass: TWorkEntityClass;
begin
  Result:= TWAnalise;
end;

procedure TWAnaliseList.GetByAlimento(AAlimentoID: String; AClear: Boolean);
begin
  if AClear then Clear;
  GetBySQL(Format(SQLWhere+'AlimentoID=%s',[EntityClass.GetEntityName,QuotedStr(AAlimentoID)]));
end;

procedure TWAnaliseList.GetByAlimentos(AAlimentosList: TStringList; AClear: Boolean);
var
  CurrSQL: String;
  i: Integer;
begin
  if AClear then Clear;
  if AAlimentosList = nil then Exit;
  if AAlimentosList.Count = 0 then Exit;

  CurrSQL:= Format(SQLWhere,[EntityClass.GetEntityName]);
  for i := 0 to AAlimentosList.Count - 1 do
  begin
    CurrSQL:= CurrSQL + Format('AlimentoID=%s',[QuotedStr(AAlimentosList[i])]);
    if i <> AAlimentosList.Count - 1 then
      CurrSQL:= CurrSQL + ' OR ';
  end;
  GetBySQL(CurrSQL);
end;

procedure TWAnaliseList.GetByCrianca(ACriancaID: String; AClear: Boolean);
begin
  if AClear then Clear;
  GetBySQL(Format(SQLWhere+'CriancaID=%s',[EntityClass.GetEntityName,QuotedStr(ACriancaID)]));
end;

function TWAnaliseList.GetItem(Index: Integer): TWAnalise;
begin
  Result:= inherited GetItem(Index) as TWAnalise;
end;

function TWAnaliseList.IndexOfAlimento(AAlimentoID: String): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameString(Items[i].bf.AlimentoID,AAlimentoID) then
      Exit(i);
  Result:= -1;
end;

function TWAnaliseList.IndexOfCrianca(ACriancaID: String): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameString(Items[i].bf.CriancaID,ACriancaID) then
      Exit(i);
  Result:= -1;
end;

function TWAnaliseList.InternalAlimento: TWAlimentos;
begin
  if not Assigned(FInternalAlimento) then
    FInternalAlimento:= TWAlimentos.Create(nil,Session);
  Result:= FInternalAlimento;
end;

function TWAnaliseList.InternalCrianca: TWCriancas;
begin
  if not Assigned(FInternalCrianca) then
    FInternalCrianca:= TWCriancas.Create(nil,Session);
  Result:= FInternalCrianca;
end;

initialization
  RegisterEntity(TWAnalise);
end.
