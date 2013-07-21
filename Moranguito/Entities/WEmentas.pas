unit WEmentas;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities, WEmentaAlimentos,
  WAlimentos;

type
  TWEmentasBf = class(TWorkEntityBf)
  private
    FEmentaID: String;
    FNome: String;
  public
  published
    property EmentaID: String read FEmentaID write FEmentaID;
    property Nome: String read FNome write FNome;
  end;

  TWEmentas = class(TWorkEntity)
  private
    FAlimentos: TWAlimentos;
    function GetAlimentos: TWAlimentos;
  protected
    function GetBf: TWEmentasBf;
  public
    destructor Destroy; override;
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(AEmentaID: String; const ALoadBf: Boolean=True): boolean;
    procedure Save; override;
    procedure Delete(AEmentaID: String); reintroduce; overload;
  published
    property bf: TWEmentasBf read GetBf;
    property Alimentos: TWAlimentos read GetAlimentos;
  end;

  TWEmentasList = class(TWorkEntityList)
  private
    function GetItem(Index: Integer): TWEmentas;
  public
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWEmentas;
    property Items[Index: Integer]: TWEmentas read GetItem; default;
  end;

implementation

{ TWEmentasBf }

{ TWEmentas }

destructor TWEmentas.Destroy;
begin
  FreeAndNil(FAlimentos);
  inherited;
end;

class function TWEmentas.BfClass: TWorkEntityBfClass;
begin
  Result:= TWEmentasBf;
end;

function TWEmentas.GetBf: TWEmentasBf;
begin
  Result:= inherited GetBf as TWEmentasBf;
end;

function TWEmentas.GetAlimentos: TWAlimentos;
begin
  if not Assigned(FAlimentos) then
    FAlimentos:= TWAlimentos.Create(nil,Session);
  //Get
  Result:= FAlimentos;
end;

class function TWEmentas.GetEntityName: string;
begin
  Result:= 'Ementas';
end;

class function TWEmentas.GetEntityPrimaryKey: string;
begin
  Result:= 'EmentaID';
end;

class function TWEmentas.GetEntityIndexs: string;
begin
  Result:= 'EmentaID';
end;

function TWEmentas.Exist(AEmentaID: String; const ALoadBf: Boolean): boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,AEmentaID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

procedure TWEmentas.Save;
begin
  inherited;
  if Exist(bf.EmentaID,False) then
    Update
  else
    Insert;
end;

procedure TWEmentas.Delete(AEmentaID: String);
begin
  inherited Delete(AEmentaID);
end;

{ TWEmentasList }

function TWEmentasList.Add: TWEmentas;
begin
  Result:= inherited Add as TWEmentas;
end;

class function TWEmentasList.EntityClass: TWorkEntityClass;
begin
  Result:= TWEmentas;
end;

function TWEmentasList.GetItem(Index: Integer): TWEmentas;
begin
  Result:= inherited GetItem(Index) as TWEmentas;
end;

initialization
  RegisterEntity(TWEmentas);
end.
