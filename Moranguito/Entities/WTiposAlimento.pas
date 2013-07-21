unit WTiposAlimento;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities, WorkTypes;

type
  TWTiposAlimentoBf = class(TWorkEntityBf)
  private
    FTipoAlimentoID: Integer;
    FNome: String;
  public
  published
    property TipoAlimentoID: Integer read FTipoAlimentoID write FTipoAlimentoID;
    property Nome: String read FNome write FNome;
  end;

  TWTiposAlimento = class(TWorkEntity)
  private
  protected
    function GetBf: TWTiposAlimentoBf;
  public
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function GetNextTipoAlimentoID: Integer;
    function Exist(ATipoAlimentoID: Integer; const ALoadBf: Boolean=True): Boolean; overload;
    function Exist(ANome: String; const ALoadBf: Boolean=True): Boolean; overload;
    procedure Validate; override;
    function HasRelations(ARaise: Boolean=True): Boolean; override;
    procedure CheckRelations(ATipoAlimentoID: Integer);
    procedure Save; override;
    function Delete(ATipoAlimentoID: Integer): Boolean; reintroduce; overload;
  published
    property bf: TWTiposAlimentoBf read GetBf;
  end;

  TWTiposAlimentoList = class(TWorkEntityList)
  private
    function GetItem(Index: Integer): TWTiposAlimento;
  public
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWTiposAlimento;
    property Items[Index: Integer]: TWTiposAlimento read GetItem; default;
  end;

implementation

uses
  WAlimentos;

{ TWTiposAlimentoBf }

{ TWTiposAlimento }

class function TWTiposAlimento.BfClass: TWorkEntityBfClass;
begin
  Result:= TWTiposAlimentoBf;
end;

function TWTiposAlimento.GetBf: TWTiposAlimentoBf;
begin
  Result:= inherited GetBf as TWTiposAlimentoBf;
end;

class function TWTiposAlimento.GetEntityName: string;
begin
  Result:= 'TiposAlimento';
end;

class function TWTiposAlimento.GetEntityPrimaryKey: string;
begin
  Result:= 'TipoAlimentoID';
end;

class function TWTiposAlimento.GetEntityIndexs: string;
begin
  Result:= 'TipoAlimentoID';
end;

function TWTiposAlimento.HasRelations(ARaise: Boolean): Boolean;
begin
  Result:= inherited HasRelations(False); //ToDo
  if ARaise then
    CheckRelations(bf.TipoAlimentoID);
end;

procedure TWTiposAlimento.CheckRelations(ATipoAlimentoID: Integer);
var
  Res: Boolean;
begin
  with TWAlimentos.Create(nil,Session) do
  try
    //ToDo: List of Tables
    Res:= ExistRecord(Format(SQLWhere+'TipoAlimentoID=%d',['Alimentos',ATipoAlimentoID]),False);
    if Res then
      raise EWorkEntity.CreateFmt('O tipo de alimento "%s" está a ser usado num alimento.',[Self.bf.Nome]);
  finally
    Free;
  end;
end;

function TWTiposAlimento.Exist(ATipoAlimentoID: Integer; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,ATipoAlimentoID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
  begin
    New;
    bf.TipoAlimentoID:= GetNextTipoAlimentoID;
  end;
end;

function TWTiposAlimento.Exist(ANome: String; const ALoadBf: Boolean): Boolean;
begin
  Result:= ExistRecord(Format(SQLWhere+'Nome=%s',[GetEntityName,
    QuotedStr(ANome)]),True);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
  begin
    New;
    bf.TipoAlimentoID:= GetNextTipoAlimentoID;
  end;
end;

procedure TWTiposAlimento.Save;
begin
  inherited;
  if Exist(bf.TipoAlimentoID,False) then
    Update
  else
    Insert;
end;

procedure TWTiposAlimento.Validate;
begin
  inherited;
  if Exist(bf.Nome,False) then
    raise EWorkEntity.CreateFmt('O tipo de alimento "%s" já existe.',[bf.Nome]);
end;

function TWTiposAlimento.Delete(ATipoAlimentoID: Integer): Boolean;
begin
  CheckRelations(ATipoAlimentoID);
  Result:= inherited Delete(ATipoAlimentoID);
end;

function TWTiposAlimento.GetNextTipoAlimentoID: Integer;
begin
  SqlTable.LoadFromSql('SELECT * FROM TiposAlimento ORDER BY TipoAlimentoID DESC LIMIT 1');
  if SqlTable.Count = 0 then
    Result:= 1
  else
    Result:= SqlTable.FieldAsInteger(SqlTable.FieldIndex['TipoAlimentoID'])+1;
end;

{ TWTiposAlimentoList }

function TWTiposAlimentoList.Add: TWTiposAlimento;
begin
  Result:= inherited Add as TWTiposAlimento;
end;

class function TWTiposAlimentoList.EntityClass: TWorkEntityClass;
begin
  Result:= TWTiposAlimento;
end;

function TWTiposAlimentoList.GetItem(Index: Integer): TWTiposAlimento;
begin
  Result:= inherited GetItem(Index) as TWTiposAlimento;
end;

initialization
  RegisterEntity(TWTiposAlimento);
end.
