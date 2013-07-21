unit Moranguito.TiposAlimentoForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI, CollectionToCxGrid,
  WTiposAlimento,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGrid, cxSplitter, cxContainer, cxLabel, cxTextEdit, Menus,
  StdCtrls, cxButtons, ActnList,
  cxGridCustomPopupMenu, cxGridPopupMenu, ImgList;

type
  TMoranguitoTiposAlimentoForm = class(TMoranguitoFormGUI)
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
    GridPopupMenu: TcxGridPopupMenu;
    PopupMenu: TPopupMenu;
    miRemover: TMenuItem;
    ActRemover: TAction;
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
    procedure edNomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FTiposAlimentoList: TWTiposAlimentoList;
    FTiposAlimentoDS: TCollectionDataSourceUser;
    function TiposAlimentoList: TWTiposAlimentoList;
    function TiposAlimentoDS: TCollectionDataSourceUser;

    procedure ConfigureGridTiposAlimento;
  public
    procedure Init; override;
    procedure Reset; override;
  end;

implementation

uses
  Utilities;

{$R *.dfm}

{ TMoranguitoTiposAlimentoForm }

procedure TMoranguitoTiposAlimentoForm.FormCreate(Sender: TObject);
begin
  FTiposAlimentoList:= nil;
  FTiposAlimentoDS:= nil;
end;

procedure TMoranguitoTiposAlimentoForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTiposAlimentoDS);
  FreeAndNil(FTiposAlimentoList);
end;

procedure TMoranguitoTiposAlimentoForm.FormShow(Sender: TObject);
begin
  edNome.SetFocus;
end;

procedure TMoranguitoTiposAlimentoForm.GridViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Idx: Integer;
  Item: TWTiposAlimento;
begin
  Idx:= ACellViewInfo.GridRecord.RecordIndex;
  if Idx < 0 then Exit;
  Item:= TiposAlimentoList[Idx];
  edID.Text:= NumberToStr(Item.bf.TipoAlimentoID);
  edNome.Text:= Trim(Item.bf.Nome);
  edNome.SetFocus;
end;

procedure TMoranguitoTiposAlimentoForm.Init;
begin
  inherited;
  TiposAlimentoList.GetAll;
  TiposAlimentoDS.AssignTableView(GridView);
  TiposAlimentoDS.DataChanged;
  ConfigureGridTiposAlimento;
end;

procedure TMoranguitoTiposAlimentoForm.Reset;
begin
  inherited;
  edID.Text:= '';
  edNome.Text:= '';
  TiposAlimentoList.GetAll;
  TiposAlimentoDS.DataChanged;
  if edNome.CanFocusEx then edNome.SetFocus;
end;

function TMoranguitoTiposAlimentoForm.TiposAlimentoList: TWTiposAlimentoList;
begin
  if not Assigned(FTiposAlimentoList) then
    FTiposAlimentoList:= TWTiposAlimentoList.Create(Ctrl.Session);
  Result:= FTiposAlimentoList;
end;

function TMoranguitoTiposAlimentoForm.TiposAlimentoDS: TCollectionDataSourceUser;
begin
  if not Assigned(FTiposAlimentoDS) then
    FTiposAlimentoDS:= TCollectionDataSourceUser.Create(TiposAlimentoList);
  Result:= FTiposAlimentoDS;
end;

procedure TMoranguitoTiposAlimentoForm.ActGravarExecute(Sender: TObject);
begin
  Ctrl.TiposAlimento.Exist(StrToNumber(edID.Text));
  Ctrl.TiposAlimento.bf.Nome:= Trim(edNome.Text);
  Ctrl.TiposAlimento.Save;
  Reset;
end;

procedure TMoranguitoTiposAlimentoForm.ActGravarUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= Trim(edNome.Text) <> '';
end;

procedure TMoranguitoTiposAlimentoForm.ActRemoverExecute(Sender: TObject);
var
  Idx: Integer;
  Item: TWTiposAlimento;
begin
  Idx:= GridView.DataController.FocusedRecordIndex;
  if Idx < 0 then Exit;
  Item:= TiposAlimentoList[Idx];
  if (MessageDlg(Format('Tem a certeza que deseja remover "%s"?',[Trim(Item.bf.Nome)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
  Item.Delete(Item.bf.TipoAlimentoID);
  Reset;
end;

procedure TMoranguitoTiposAlimentoForm.ActRemoverUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= GridView.DataController.FocusedRecordIndex >= 0;
end;

procedure TMoranguitoTiposAlimentoForm.btCancelarClick(Sender: TObject);
begin
  Reset;
end;

procedure TMoranguitoTiposAlimentoForm.ConfigureGridTiposAlimento;
var
  Column: TcxGridColumn;
begin
  Column:= TiposAlimentoDS.GetColumnByFieldName(GridView,'TipoAlimentoID');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Código';
    Column.Width:= 50;
    Column.SortOrder:= soAscending;
  end;
  Column:= TiposAlimentoDS.GetColumnByFieldName(GridView,'Nome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Tipo de Alimento';
  end;
  GridView.OptionsView.ColumnAutoWidth:= True;
end;

procedure TMoranguitoTiposAlimentoForm.edNomeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and btGravar.CanFocus then
  begin
    btGravar.SetFocus;
  end;
end;

end.
