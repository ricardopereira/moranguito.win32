unit Moranguito.Controller;

interface

uses
  WorkEngine, WorkSession, CollectionToCxGrid,
  WAlimentos, WCriancas, WTiposAlimento, WAnalise,
  {Auto} SysUtils, Classes;

type
  TCtrl = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FSession: TWorkSession;
    FAlimentos: TWAlimentos;
    FCriancas: TWCriancas;
    FTiposAlimento: TWTiposAlimento;
    FAnalise: TWAnalise;
    function GetAlimentos: TWAlimentos;
    function GetCriancas: TWCriancas;
    function GetTiposAlimento: TWTiposAlimento;
    function GetAnalise: TWAnalise;
  public
    property Session: TWorkSession read FSession;
    property Alimentos: TWAlimentos read GetAlimentos;
    property Criancas: TWCriancas read GetCriancas;
    property TiposAlimento: TWTiposAlimento read GetTiposAlimento;
    property Analise: TWAnalise read GetAnalise;
  end;

var
  Ctrl: TCtrl;

implementation

{$R *.dfm}

procedure TCtrl.DataModuleCreate(Sender: TObject);
begin
  FSession:= TWorkSession.Create(_CorePoint);
  FAlimentos:= nil;
  FCriancas:= nil;
  FTiposAlimento:= nil;
  FAnalise:= nil;

  Session.Init;
end;

procedure TCtrl.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FAlimentos);
  FreeAndNil(FCriancas);
  FreeAndNil(FTiposAlimento);
  FreeAndNil(FAnalise);
  FreeAndNil(FSession);
end;

function TCtrl.GetAlimentos: TWAlimentos;
begin
  if not Assigned(FAlimentos) then
    FAlimentos:= TWAlimentos.Create(nil,Session);
  Result:= FAlimentos;
end;

function TCtrl.GetCriancas: TWCriancas;
begin
  if not Assigned(FCriancas) then
    FCriancas:= TWCriancas.Create(nil,Session);
  Result:= FCriancas;
end;

function TCtrl.GetTiposAlimento: TWTiposAlimento;
begin
  if not Assigned(FTiposAlimento) then
    FTiposAlimento:= TWTiposAlimento.Create(nil,Session);
  Result:= FTiposAlimento;
end;

function TCtrl.GetAnalise: TWAnalise;
begin
  if not Assigned(FAnalise) then
    FAnalise:= TWAnalise.Create(nil,Session);
  Result:= FAnalise;
end;

end.
