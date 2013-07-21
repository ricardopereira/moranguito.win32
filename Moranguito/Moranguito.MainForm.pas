unit Moranguito.MainForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinsDefaultPainters, dxSkinsdxBarPainter, cxClasses,
  dxBar, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxStatusBar, ImgList, cxContainer, cxEdit, cxLabel,
  dxGDIPlusClasses, cxStyles, dxBarExtItems, ActnList;

type
  TMoranguitoMainForm = class(TForm)
    BarManager: TdxBarManager;
    Container: TPanel;
    BarManagerPrincipal: TdxBar;
    StatusBar: TdxStatusBar;
    btAlimentos: TdxBarLargeButton;
    btCriancas: TdxBarLargeButton;
    btTiposAlimento: TdxBarLargeButton;
    btAnalise: TdxBarLargeButton;
    btEmentas: TdxBarLargeButton;
    ImageList: TcxImageList;
    Logo: TImage;
    lblLogo: TcxLabel;
    BarDockControl: TdxBarDockControl;
    BarManagerForm: TdxBar;
    btFechar: TdxBarButton;
    btCapitulo: TdxBarStatic;
    StyleRepository: TcxStyleRepository;
    StyleBold: TcxStyle;
    ActionList: TActionList;
    ActFechar: TAction;
    ImageList16: TcxImageList;
    procedure btTiposAlimentoClick(Sender: TObject);
    procedure btCriancasClick(Sender: TObject);
    procedure btAnaliseClick(Sender: TObject);
    procedure btAlimentosClick(Sender: TObject);
    procedure btEmentasClick(Sender: TObject);
    procedure ActFecharExecute(Sender: TObject);
    procedure ActFecharUpdate(Sender: TObject);
  private
    FActiveForm: TMoranguitoFormGUI;
    procedure CallForm(AFormClass: TMoranguitoFormGUIClass);
  public
  end;

var
  MoranguitoMainForm: TMoranguitoMainForm;

implementation

uses
  Moranguito.TiposAlimentoForm, Moranguito.AlimentosForm, Moranguito.CriancasForm,
  Moranguito.AnaliseForm, Moranguito.EmentasForm;

{$R *.dfm}

procedure TMoranguitoMainForm.CallForm(AFormClass: TMoranguitoFormGUIClass);
begin
  if AFormClass = nil then Exit;
  //Check if is open
  if FActiveForm <> nil then
  begin
    if FActiveForm.ClassNameIs(AFormClass.ClassName) then Exit;
    FActiveForm.Free;
    FActiveForm:= nil;
  end;
  FActiveForm:= AFormClass.Create(Self);

  FActiveForm.OnRelease:= procedure
    begin
      FActiveForm:= nil;
    end;
  btCapitulo.Caption:= FActiveForm.Caption;
  FActiveForm.Init;
  FActiveForm.ShowParented(Container);
end;

procedure TMoranguitoMainForm.ActFecharExecute(Sender: TObject);
begin
  if FActiveForm <> nil then
    FActiveForm.Release;
end;

procedure TMoranguitoMainForm.ActFecharUpdate(Sender: TObject);
begin
  BarDockControl.Visible:= FActiveForm <> nil;
end;

procedure TMoranguitoMainForm.btAlimentosClick(Sender: TObject);
begin
  CallForm(TMoranguitoAlimentosForm);
end;

procedure TMoranguitoMainForm.btCriancasClick(Sender: TObject);
begin
  CallForm(TMoranguitoCriancasForm);
end;

procedure TMoranguitoMainForm.btTiposAlimentoClick(Sender: TObject);
begin
  CallForm(TMoranguitoTiposAlimentoForm);
end;

procedure TMoranguitoMainForm.btAnaliseClick(Sender: TObject);
begin
  CallForm(TMoranguitoAnaliseForm);
end;

procedure TMoranguitoMainForm.btEmentasClick(Sender: TObject);
begin
  CallForm(TMoranguitoEmentasForm);
end;

end.
