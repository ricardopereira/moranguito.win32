unit Moranguito.AlimentosForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI, CollectionToCxGrid,
  WAlimentos, WTiposAlimento,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGrid, cxSplitter, cxContainer, cxLabel, cxTextEdit, Menus,
  StdCtrls, cxButtons, ActnList,
  cxMaskEdit, cxDropDownEdit, cxGridCustomPopupMenu, cxGridPopupMenu, ImgList;

type
  TMoranguitoAlimentosForm = class(TMoranguitoFormGUI)
    pnlMain: TPanel;
    GridLevel: TcxGridLevel;
    Grid: TcxGrid;
    GridView: TcxGridTableView;
    pnlDados: TPanel;
    Splitter: TcxSplitter;
    edNome: TcxTextEdit;
    lblNome: TcxLabel;
    btGravar: TcxButton;
    btCancelar: TcxButton;
    ActionList: TActionList;
    ActGravar: TAction;
    lblID: TcxLabel;
    edID: TcxTextEdit;
    cboTiposAlimento: TcxComboBox;
    lblTipoAlimento: TcxLabel;
    ActRemover: TAction;
    PopupMenu: TPopupMenu;
    miRemover: TMenuItem;
    GridPopupMenu: TcxGridPopupMenu;
    ImageList: TcxImageList;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure ActGravarExecute(Sender: TObject);
    procedure ActGravarUpdate(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure ActRemoverExecute(Sender: TObject);
    procedure ActRemoverUpdate(Sender: TObject);
  private
    FAlimentosList: TWAlimentosList;
    FAlimentosDS: TCollectionDataSourceUser;
    FTiposAlimentoList: TWTiposAlimentoList;
    function AlimentosList: TWAlimentosList;
    function AlimentosDS: TCollectionDataSourceUser;
    function TiposAlimentoList: TWTiposAlimentoList;

    procedure ConfigureGridAlimentos;
  protected
    procedure LoadTiposAlimento;
  public
    procedure Init; override;
    procedure Reset; override;
  end;

implementation

uses
  Utilities;

{$R *.dfm}

{ TMoranguitoAlimentosForm }

procedure TMoranguitoAlimentosForm.FormCreate(Sender: TObject);
begin
  FAlimentosList:= nil;
  FAlimentosDS:= nil;
  FTiposAlimentoList:= nil;
end;

procedure TMoranguitoAlimentosForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTiposAlimentoList);
  FreeAndNil(FAlimentosDS);
  FreeAndNil(FAlimentosList);
end;

procedure TMoranguitoAlimentosForm.FormShow(Sender: TObject);
begin
  edNome.SetFocus;
end;

procedure TMoranguitoAlimentosForm.GridViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Idx: Integer;
  Item: TWAlimentos;
  i: Integer;
begin
  Idx:= ACellViewInfo.GridRecord.RecordIndex;
  if Idx < 0 then Exit;
  Item:= AlimentosList[Idx];
  edID.Text:= Trim(Item.bf.AlimentoID);
  edNome.Text:= Trim(Item.bf.Nome);

  for i := 0 to TiposAlimentoList.Count - 1 do
    if SameString(TiposAlimentoList[i].bf.Nome,cboTiposAlimento.Properties.Items[i]) then
    begin
      cboTiposAlimento.ItemIndex:= i;
      Break;
    end;

  edNome.SetFocus;
end;

procedure TMoranguitoAlimentosForm.Init;
begin
  inherited;
  if Ctrl.TiposAlimento.GetRecordsCount = 0 then
    raise Exception.Create('Insira primeiro os tipos de alimento.');
  LoadTiposAlimento;
  AlimentosList.GetAll;
  AlimentosDS.AssignTableView(GridView);
  AlimentosDS.DataChanged;
  ConfigureGridAlimentos;
end;

procedure TMoranguitoAlimentosForm.Reset;
begin
  inherited;
  edID.Text:= '';
  edNome.Text:= '';
  LoadTiposAlimento;
  AlimentosList.GetAll;
  AlimentosDS.DataChanged;
  if edNome.CanFocusEx then edNome.SetFocus;
end;

procedure TMoranguitoAlimentosForm.LoadTiposAlimento;
var
  i: Integer;
begin
  TiposAlimentoList.GetAll;
  cboTiposAlimento.Properties.Items.Clear;
  for i := 0 to TiposAlimentoList.Count - 1 do
  begin
    cboTiposAlimento.Properties.Items.Add(TiposAlimentoList[i].bf.Nome);
  end;
  if cboTiposAlimento.Properties.Items.Count > 0 then
    cboTiposAlimento.ItemIndex:= 0;
end;

function TMoranguitoAlimentosForm.AlimentosList: TWAlimentosList;
begin
  if not Assigned(FAlimentosList) then
    FAlimentosList:= TWAlimentosList.Create(Ctrl.Session);
  Result:= FAlimentosList;
end;

function TMoranguitoAlimentosForm.AlimentosDS: TCollectionDataSourceUser;
begin
  if not Assigned(FAlimentosDS) then
    FAlimentosDS:= TCollectionDataSourceUser.Create(AlimentosList,'Nome,TipoAlimentoNome');
  Result:= FAlimentosDS;
end;

function TMoranguitoAlimentosForm.TiposAlimentoList: TWTiposAlimentoList;
begin
  if not Assigned(FTiposAlimentoList) then
    FTiposAlimentoList:= TWTiposAlimentoList.Create(Ctrl.Session);
  Result:= FTiposAlimentoList;
end;

procedure TMoranguitoAlimentosForm.ActGravarExecute(Sender: TObject);
begin
  if cboTiposAlimento.ItemIndex < 0 then
    raise Exception.Create('É necessário seleccionar um tipo de alimento.');

  if not Ctrl.Alimentos.Exist(edID.Text) then
    Ctrl.Alimentos.bf.AlimentoID:= NewGUIDStr;
  Ctrl.Alimentos.bf.Nome:= Trim(edNome.Text);
  Ctrl.Alimentos.bf.TipoAlimentoID:= TiposAlimentoList[cboTiposAlimento.ItemIndex].bf.TipoAlimentoID;
  Ctrl.Alimentos.Save;
  Reset;
end;

procedure TMoranguitoAlimentosForm.ActGravarUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= Trim(edNome.Text) <> '';
end;

procedure TMoranguitoAlimentosForm.ActRemoverExecute(Sender: TObject);
var
  Idx: Integer;
  Item: TWAlimentos;
begin
  Idx:= GridView.DataController.FocusedRecordIndex;
  if Idx < 0 then Exit;
  Item:= AlimentosList[Idx];
  if (MessageDlg(Format('Tem a certeza que deseja remover "%s"?',[Trim(Item.bf.Nome)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
  Item.Delete(Item.bf.AlimentoID);
  Reset;
end;

procedure TMoranguitoAlimentosForm.ActRemoverUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= GridView.DataController.FocusedRecordIndex >= 0;
end;

procedure TMoranguitoAlimentosForm.btCancelarClick(Sender: TObject);
begin
  Reset;
end;

procedure TMoranguitoAlimentosForm.ConfigureGridAlimentos;
var
  Column: TcxGridColumn;
begin
  Column:= AlimentosDS.GetColumnByFieldName(GridView,'Nome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Alimento';
    Column.SortOrder:= soAscending;
  end;
  Column:= AlimentosDS.GetColumnByFieldName(GridView,'TipoAlimentoNome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Tipo';
  end;
  GridView.OptionsView.ColumnAutoWidth:= True;
end;

end.
