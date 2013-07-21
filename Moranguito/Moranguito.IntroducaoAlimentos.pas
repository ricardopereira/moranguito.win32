unit Moranguito.IntroducaoAlimentos;

interface

uses
  SysUtils, Classes, WorkEntityClasses, WCriancas, WAnalise;

type
  TIntroducaoAlimentos = class(TCoreController)
  private
    FCriancasValidas: TWCriancasList;
    FCriancasInvalidas: TWCriancasList;
    FAnaliseList: TWAnaliseList;
    function GetCriancasValidas: TWCriancasList;
    function GetCriancasInvalidas: TWCriancasList;
    function GetAnaliseList: TWAnaliseList;
  published
  public
    destructor Destroy; override;
    procedure Load(AAlimentosList: TStringList);
    property CriancasValidas: TWCriancasList read GetCriancasValidas;
    property CriancasInvalidas: TWCriancasList read GetCriancasInvalidas;
  end;

implementation

{ TIntroducaoAlimentos }

destructor TIntroducaoAlimentos.Destroy;
begin
  FreeAndNil(FCriancasValidas);
  FreeAndNil(FCriancasInvalidas);
  FreeAndNil(FAnaliseList);
  inherited;
end;

procedure TIntroducaoAlimentos.Load(AAlimentosList: TStringList);
var
  i,j: Integer;
  ValidoItem,InvalidoItem: TWCriancas;
begin
  CriancasValidas.Clear;
  CriancasInvalidas.Clear;
  if AAlimentosList = nil then Exit;
  if AAlimentosList.Count = 0 then Exit;

  CriancasValidas.GetAll;
  for i := CriancasValidas.Count - 1 downto 0 do
  begin
    ValidoItem:= CriancasValidas[i];
    InvalidoItem:= nil;
    //Lista de Alimentos Válidos
    GetAnaliseList.GetByCrianca(ValidoItem.bf.CriancaID);
    //Verificar alimentos
    for j := 0 to AAlimentosList.Count - 1 do
    begin
      if GetAnaliseList.IndexOfAlimento(AAlimentosList[j]) < 0 then
      begin
        //Inválido
        if InvalidoItem = nil then
        begin
          InvalidoItem:= CriancasInvalidas.Add;
          InvalidoItem.Assign(ValidoItem);
        end;
        InvalidoItem.AlimentosList.Add.Exist(AAlimentosList[j]);
      end;
    end;
    if InvalidoItem <> nil then
      ValidoItem.Free;
  end;
end;

function TIntroducaoAlimentos.GetCriancasValidas: TWCriancasList;
begin
  if not Assigned(FCriancasValidas) then
    FCriancasValidas:= TWCriancasList.Create(Session);
  Result:= FCriancasValidas;
end;

function TIntroducaoAlimentos.GetCriancasInvalidas: TWCriancasList;
begin
  if not Assigned(FCriancasInvalidas) then
    FCriancasInvalidas:= TWCriancasList.Create(Session);
  Result:= FCriancasInvalidas;
end;

function TIntroducaoAlimentos.GetAnaliseList: TWAnaliseList;
begin
  if not Assigned(FAnaliseList) then
    FAnaliseList:= TWAnaliseList.Create(Session);
  Result:= FAnaliseList;
end;

end.
