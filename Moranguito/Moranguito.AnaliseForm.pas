unit Moranguito.AnaliseForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI, CollectionToCxGrid,
  WAnalise, WAlimentos, WCriancas,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGrid, cxSplitter, cxContainer, cxLabel, cxTextEdit, Menus,
  StdCtrls, cxButtons, ActnList, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinValentine, dxSkinXmas2008Blue,
  cxCheckBox, cxEditRepositoryItems;

type
  TMoranguitoAnaliseForm = class(TMoranguitoFormGUI)
    pnlMain: TPanel;
    Grid: TcxGrid;
    GridView: TcxGridTableView;
    GridLevel: TcxGridLevel;
    EditRepository: TcxEditRepository;
    EditRepositoryTextItem: TcxEditRepositoryTextItem;
    StyleRepository: TcxStyleRepository;
    StyleAlimento: TcxStyle;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridViewEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
  private
    FAnaliseList: TWAnaliseList;
    FAlimentosList: TWAlimentosList;
    FCriancasList: TWCriancasList;
    function AnaliseList: TWAnaliseList;
    function AlimentosList: TWAlimentosList;
    function CriancasList: TWCriancasList;

    procedure ColumnAlimentoGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);

    procedure Save(AAlimentoID,ACriancaID: String);
  protected
    procedure LoadCriancas;
    procedure LoadAlimentos;
  public
    procedure Init; override;
    procedure Reset; override;
  end;

implementation

uses
  Utilities;

{$R *.dfm}

{ TMoranguitoAnaliseForm }

procedure TMoranguitoAnaliseForm.FormCreate(Sender: TObject);
begin
  FAnaliseList:= nil;
  FAlimentosList:= nil;
  FCriancasList:= nil;
end;

procedure TMoranguitoAnaliseForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAnaliseList);
  FreeAndNil(FAlimentosList);
  FreeAndNil(FCriancasList);
end;

procedure TMoranguitoAnaliseForm.Init;
begin
  inherited;
  if (Ctrl.Alimentos.GetRecordsCount = 0) or (Ctrl.Criancas.GetRecordsCount = 0) then
    raise Exception.Create('É necessário adicionar alimentos e crianças.');

  AnaliseList.GetAll;
  AlimentosList.GetAll;
  CriancasList.GetAll;

  GridView.OptionsCustomize.ColumnMoving:= False;
  with GridView.CreateColumn do
  begin
    Caption:= 'Alimento';
    Width:= 100;
    HeaderAlignmentHorz:= taCenter;
    HeaderAlignmentVert:= vaCenter;
    Styles.Header:= StyleAlimento;
    Styles.Content:= StyleAlimento;
    OnGetProperties:= ColumnAlimentoGetProperties;
  end;
  with GridView.CreateColumn do
  begin
    Caption:= 'Tipo de Alimento';
    OnGetProperties:= ColumnAlimentoGetProperties;
    GroupBy(0,False);
  end;

  LoadCriancas;
  LoadAlimentos;

  GridView.ViewData.Expand(False);
end;

procedure TMoranguitoAnaliseForm.Reset;
begin
  inherited;

end;

function TMoranguitoAnaliseForm.AnaliseList: TWAnaliseList;
begin
  if not Assigned(FAnaliseList) then
    FAnaliseList:= TWAnaliseList.Create(Ctrl.Session);
  Result:= FAnaliseList;
end;

function TMoranguitoAnaliseForm.AlimentosList: TWAlimentosList;
begin
  if not Assigned(FAlimentosList) then
    FAlimentosList:= TWAlimentosList.Create(Ctrl.Session);
  Result:= FAlimentosList;
end;

function TMoranguitoAnaliseForm.CriancasList: TWCriancasList;
begin
  if not Assigned(FCriancasList) then
    FCriancasList:= TWCriancasList.Create(Ctrl.Session);
  Result:= FCriancasList;
end;

procedure TMoranguitoAnaliseForm.LoadAlimentos;
var
  i,j,Idx: Integer;
  AlimentoItem: TWAlimentos;
  CriancaItem: TWCriancas;
begin
  for i := 0 to AlimentosList.Count - 1 do
  begin
    AlimentoItem:= AlimentosList[i];

    Idx:= GridView.DataController.AppendRecord;
    GridView.DataController.Values[Idx,0]:= AlimentoItem.bf.Nome;
    GridView.DataController.Values[Idx,1]:= AlimentoItem.bf.TipoAlimentoNome;
    GridView.DataController.Post;

    for j := 0 to CriancasList.Count - 1 do
    begin
      CriancaItem:= CriancasList[j];
      GridView.DataController.Values[Idx,CriancaItem.Index + 2]:= Ctrl.Analise.Exist(AlimentoItem.bf.AlimentoID,CriancaItem.bf.CriancaID,False);
    end;
  end;
end;

procedure TMoranguitoAnaliseForm.Save(AAlimentoID, ACriancaID: String);
begin
  if Ctrl.Analise.Exist(AAlimentoID,ACriancaID) then
  begin
    Ctrl.Analise.Delete;
    Exit;
  end;
  Ctrl.Analise.bf.AnaliseID:= NewGUIDStr;
  Ctrl.Analise.bf.AlimentoID:= AAlimentoID;
  Ctrl.Analise.bf.CriancaID:= ACriancaID;
  Ctrl.Analise.Save;
end;

procedure TMoranguitoAnaliseForm.LoadCriancas;
var
  i: Integer;
  Column: TcxGridColumn;
  Item: TWCriancas;
begin
  for i := 0 to CriancasList.Count - 1 do
  begin
    Item:= CriancasList[i];
    Column:= GridView.CreateColumn;
    Column.HeaderAlignmentHorz:= taCenter;
    Column.HeaderAlignmentVert:= vaCenter;
    Column.PropertiesClass:= TcxCheckBoxProperties;
    //TcxCheckBoxProperties(Column.Properties)
    Column.Caption:= Item.bf.Nome;
  end;
end;

procedure TMoranguitoAnaliseForm.ColumnAlimentoGetProperties(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  AProperties:= EditRepositoryTextItem.Properties;
end;

procedure TMoranguitoAnaliseForm.GridViewEditValueChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  Save(AlimentosList[GridView.DataController.EditingRecordIndex].bf.AlimentoID,
    CriancasList[AItem.Index-2].bf.CriancaID);
end;

end.
