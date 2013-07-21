unit WEmentaAlimentos;

interface

uses
  SysUtils, Classes, WorkEngine, WorkEntityClasses, Utilities;

type
  TWEmentaAlimentosBf = class(TWorkEntityBf)
  private
    FEmentaAlimentosID: String;
    FEmentaID: String;
    FAlimentoID: String;
  public
  published
    property EmentaAlimentosID: String read FEmentaAlimentosID write FEmentaAlimentosID;
    property EmentaID: String read FEmentaID write FEmentaID;
    property AlimentoID: String read FAlimentoID write FAlimentoID;
  end;

  TWEmentaAlimentos = class(TWorkEntity)
  private
  protected
    function GetBf: TWEmentaAlimentosBf;
  public
    class function BfClass: TWorkEntityBfClass; override;
    class function GetEntityName: string; override;
    class function GetEntityPrimaryKey: string; override;
    class function GetEntityIndexs: string; override;

    function Exist(AEmentaAlimentosID: String; const ALoadBf: Boolean=True): boolean;
    procedure Save; override;
    procedure Delete(AEmentaAlimentosID: String); reintroduce; overload;
  published
    property bf: TWEmentaAlimentosBf read GetBf;
  end;

  TWEmentaAlimentosList = class(TWorkEntityList)
  private
    function GetItem(Index: Integer): TWEmentaAlimentos;
  public
    class function EntityClass: TWorkEntityClass; override;
    function Add: TWEmentaAlimentos;
    property Items[Index: Integer]: TWEmentaAlimentos read GetItem; default;
  end;

implementation

{ TWEmentaAlimentosBf }

{ TWEmentaAlimentos }

class function TWEmentaAlimentos.BfClass: TWorkEntityBfClass;
begin
  Result:= TWEmentaAlimentosBf;
end;

function TWEmentaAlimentos.GetBf: TWEmentaAlimentosBf;
begin
  Result:= inherited GetBf as TWEmentaAlimentosBf;
end;

class function TWEmentaAlimentos.GetEntityName: string;
begin
  Result:= 'EmentaAlimentos';
end;

class function TWEmentaAlimentos.GetEntityPrimaryKey: string;
begin
  Result:= 'EmentaAlimentosID';
end;

class function TWEmentaAlimentos.GetEntityIndexs: string;
begin
  Result:= 'EmentaAlimentosID';
end;

function TWEmentaAlimentos.Exist(AEmentaAlimentosID: String; const ALoadBf: Boolean): boolean;
begin
  Result:= ExistRecord(GetEntityPrimaryKey,AEmentaAlimentosID);
  if Result and ALoadBf then
  begin
    AssignSqlToBf;
  end
  else if ALoadBf then
    New;
end;

procedure TWEmentaAlimentos.Save;
begin
  inherited;
  if Exist(bf.EmentaAlimentosID,False) then
    Update
  else
    Insert;
end;

procedure TWEmentaAlimentos.Delete(AEmentaAlimentosID: String);
begin
  inherited Delete(AEmentaAlimentosID);
end;

{ TWEmentaAlimentosList }

function TWEmentaAlimentosList.Add: TWEmentaAlimentos;
begin
  Result:= inherited Add as TWEmentaAlimentos;
end;

class function TWEmentaAlimentosList.EntityClass: TWorkEntityClass;
begin
  Result:= TWEmentaAlimentos;
end;

function TWEmentaAlimentosList.GetItem(Index: Integer): TWEmentaAlimentos;
begin
  Result:= inherited GetItem(Index) as TWEmentaAlimentos;
end;

initialization
  RegisterEntity(TWEmentaAlimentos);
end.
