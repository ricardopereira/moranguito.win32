unit Moranguito.CriancasForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI, CollectionToCxGrid,
  WCriancas,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGrid, cxSplitter, cxContainer, cxLabel, cxTextEdit, Menus,
  StdCtrls, cxButtons, ActnList, cxGridCustomPopupMenu, cxGridPopupMenu, ImgList;

type
  TMoranguitoCriancasForm = class(TMoranguitoFormGUI)
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
    procedure edNomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCriancasList: TWCriancasList;
    FCriancasDS: TCollectionDataSourceUser;
    function CriancasList: TWCriancasList;
    function CriancasDS: TCollectionDataSourceUser;

    procedure ConfigureGridCriancas;
  public
    procedure Init; override;
    procedure Reset; override;
  end;

implementation

uses
  Utilities;

{$R *.dfm}

{ TMoranguitoCriancasForm }

procedure TMoranguitoCriancasForm.FormCreate(Sender: TObject);
begin
  FCriancasList:= nil;
  FCriancasDS:= nil;
end;

procedure TMoranguitoCriancasForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCriancasDS);
  FreeAndNil(FCriancasList);
end;

procedure TMoranguitoCriancasForm.FormShow(Sender: TObject);
begin
  edNome.SetFocus;
end;

procedure TMoranguitoCriancasForm.GridViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Idx: Integer;
  Item: TWCriancas;
begin
  Idx:= ACellViewInfo.GridRecord.RecordIndex;
  if Idx < 0 then Exit;
  Item:= CriancasList[Idx];
  edID.Text:= Trim(Item.bf.CriancaID);
  edNome.Text:= Trim(Item.bf.Nome);
  edNome.SetFocus;
end;

procedure TMoranguitoCriancasForm.Init;
begin
  inherited;
  CriancasList.GetAll;
  CriancasDS.AssignTableView(GridView);
  CriancasDS.DataChanged;
  ConfigureGridCriancas;
end;

procedure TMoranguitoCriancasForm.Reset;
begin
  inherited;
  edID.Text:= '';
  edNome.Text:= '';
  CriancasList.GetAll;
  CriancasDS.DataChanged;
  if edNome.CanFocusEx then edNome.SetFocus;
end;

function TMoranguitoCriancasForm.CriancasList: TWCriancasList;
begin
  if not Assigned(FCriancasList) then
    FCriancasList:= TWCriancasList.Create(Ctrl.Session);
  Result:= FCriancasList;
end;

procedure TMoranguitoCriancasForm.edNomeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and btGravar.CanFocus then
  begin
    btGravar.SetFocus;
  end;
end;

function TMoranguitoCriancasForm.CriancasDS: TCollectionDataSourceUser;
begin
  if not Assigned(FCriancasDS) then
    FCriancasDS:= TCollectionDataSourceUser.Create(CriancasList,'Nome');
  Result:= FCriancasDS;
end;

procedure TMoranguitoCriancasForm.ActGravarExecute(Sender: TObject);
begin
  if not Ctrl.Criancas.Exist(Trim(edID.Text)) then
    Ctrl.Criancas.bf.CriancaID:= NewGUIDStr;
  Ctrl.Criancas.bf.Nome:= Trim(edNome.Text);
  Ctrl.Criancas.Save;
  Reset;
end;

procedure TMoranguitoCriancasForm.ActGravarUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= Trim(edNome.Text) <> '';
end;

procedure TMoranguitoCriancasForm.ActRemoverExecute(Sender: TObject);
var
  Idx: Integer;
  Item: TWCriancas;
begin
  Idx:= GridView.DataController.FocusedRecordIndex;
  if Idx < 0 then Exit;
  Item:= CriancasList[Idx];
  if (MessageDlg(Format('Tem a certeza que deseja remover "%s"?',[Trim(Item.bf.Nome)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
  Item.Delete(Item.bf.CriancaID);
  Reset;
end;

procedure TMoranguitoCriancasForm.ActRemoverUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= GridView.DataController.FocusedRecordIndex >= 0;
end;

procedure TMoranguitoCriancasForm.btCancelarClick(Sender: TObject);
begin
  Reset;
end;

procedure TMoranguitoCriancasForm.ConfigureGridCriancas;
var
  Column: TcxGridColumn;
begin
  Column:= CriancasDS.GetColumnByFieldName(GridView,'Nome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Criança';
    Column.SortOrder:= soAscending;
  end;
  GridView.OptionsView.ColumnAutoWidth:= True;
end;

end.
