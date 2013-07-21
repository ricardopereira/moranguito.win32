program Moranguito;

uses
  Forms,
  Windows,
  Moranguito.Controller in 'Moranguito.Controller.pas' {Ctrl: TDataModule},
  SQLite3Udf in '..\Core\SQLEngine\SQLite3Udf.pas',
  SQLiteCore in '..\Core\SQLEngine\SQLiteCore.pas',
  SQLiteDB in '..\Core\SQLEngine\SQLiteDB.pas',
  CollectionToCxGrid in '..\Core\CollectionToCxGrid.pas',
  Utilities in '..\Core\Utilities.pas',
  WorkClasses in '..\Core\WorkClasses.pas',
  WorkEntityClasses in '..\Core\WorkEntityClasses.pas',
  WorkEngine in '..\Core\WorkEngine.pas',
  WorkSession in '..\Core\WorkSession.pas',
  WorkTypes in '..\Core\WorkTypes.pas',
  Moranguito.MainForm in 'Moranguito.MainForm.pas' {MoranguitoMainForm},
  WAlimentos in 'Entities\WAlimentos.pas',
  WCriancas in 'Entities\WCriancas.pas',
  WTiposAlimento in 'Entities\WTiposAlimento.pas',
  WEmentas in 'Entities\WEmentas.pas',
  WAnalise in 'Entities\WAnalise.pas',
  WEmentaAlimentos in 'Entities\WEmentaAlimentos.pas',
  Moranguito.FormGUI in 'Moranguito.FormGUI.pas',
  Moranguito.TiposAlimentoForm in 'Moranguito.TiposAlimentoForm.pas' {MoranguitoTiposAlimentoForm},
  Moranguito.CriancasForm in 'Moranguito.CriancasForm.pas' {MoranguitoCriancasForm},
  Moranguito.AnaliseForm in 'Moranguito.AnaliseForm.pas' {MoranguitoAnaliseForm},
  Moranguito.AlimentosForm in 'Moranguito.AlimentosForm.pas' {MoranguitoAlimentosForm},
  Moranguito.EmentasForm in 'Moranguito.EmentasForm.pas' {MoranguitoEmentasForm},
  Moranguito.IntroducaoAlimentos in 'Moranguito.IntroducaoAlimentos.pas';

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Morango!';
  Application.CreateForm(TCtrl, Ctrl);
  Application.CreateForm(TMoranguitoMainForm, MoranguitoMainForm);
  Application.Run;
end.
