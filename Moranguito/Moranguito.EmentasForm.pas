unit Moranguito.EmentasForm;

interface

uses
  Moranguito.Controller, Moranguito.FormGUI, Moranguito.IntroducaoAlimentos,
  CollectionToCxGrid, WEmentas, WEmentaAlimentos, WAlimentos, WAnalise, WCriancas,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxContainer, ActnList, cxSplitter,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGrid,
  cxCheckListBox, StdCtrls, cxCheckBox, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter;

type
  TMoranguitoEmentasForm = class(TMoranguitoFormGUI)
    pnlMain: TPanel;
    pnlTop: TPanel;
    GridPanel: TGridPanel;
    pnlValidos: TPanel;
    GridValidos: TcxGrid;
    GridValidosView: TcxGridTableView;
    GridValidosLevel: TcxGridLevel;
    pnlInvalidos: TPanel;
    GridInvalidos: TcxGrid;
    GridInvalidosView: TcxGridTableView;
    GridInvalidosLevel: TcxGridLevel;
    gbAlimentos: TGroupBox;
    CheckListAlimentos: TcxCheckListBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckListAlimentosEditValueChanged(Sender: TObject);
  private
    FIntroducaoAlimentos: TIntroducaoAlimentos;
    FAlimentosList: TWAlimentosList;
    FCriancasValidasDS: TCollectionDataSourceUser;
    FCriancasInvalidasDS: TCollectionDataSourceUser;
    function IntroducaoAlimentos: TIntroducaoAlimentos;
    function AlimentosList: TWAlimentosList;

    function CriancasValidasDS: TCollectionDataSourceUser;
    function CriancasInvalidasDS: TCollectionDataSourceUser;

    procedure ConfigureGridAnalise(AView: TcxGridTableView; ADS: TCollectionDataSourceUser);
  protected
    procedure LoadAlimentos;
  public
    procedure Init; override;
    procedure Reset; override;
  end;

implementation

uses
  Utilities;

{$R *.dfm}

{ TMoranguitoEmentasForm }

procedure TMoranguitoEmentasForm.FormCreate(Sender: TObject);
begin
  FIntroducaoAlimentos:= nil;
  FAlimentosList:= nil;
  FCriancasValidasDS:= nil;
  FCriancasInvalidasDS:= nil;
end;

procedure TMoranguitoEmentasForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCriancasValidasDS);
  FreeAndNil(FCriancasInvalidasDS);
  FreeAndNil(FIntroducaoAlimentos);
  FreeAndNil(FAlimentosList);
end;

procedure TMoranguitoEmentasForm.Init;
begin
  inherited;
  AlimentosList.GetAll;

  CriancasValidasDS.AssignTableView(GridValidosView);
  ConfigureGridAnalise(GridValidosView,CriancasValidasDS);

  CriancasInvalidasDS.AssignTableView(GridInvalidosView);
  ConfigureGridAnalise(GridInvalidosView,CriancasInvalidasDS);

  LoadAlimentos;
end;

procedure TMoranguitoEmentasForm.LoadAlimentos;
var
  i: Integer;
begin
  CheckListAlimentos.Items.Clear;
  for i := 0 to AlimentosList.Count - 1 do
  begin
    with CheckListAlimentos.Items.Add do
    begin
      ItemObject:= AlimentosList[i];
      Caption:= (ItemObject as TWAlimentos).bf.Nome;
      Text:= (ItemObject as TWAlimentos).bf.Nome;
    end;
  end;
end;

procedure TMoranguitoEmentasForm.Reset;
begin
  inherited;

end;

function TMoranguitoEmentasForm.IntroducaoAlimentos: TIntroducaoAlimentos;
begin
  if not Assigned(FIntroducaoAlimentos) then
    FIntroducaoAlimentos:= TIntroducaoAlimentos.Create(nil,Ctrl.Session);
  Result:= FIntroducaoAlimentos;
end;

function TMoranguitoEmentasForm.AlimentosList: TWAlimentosList;
begin
  if not Assigned(FAlimentosList) then
    FAlimentosList:= TWAlimentosList.Create(Ctrl.Session);
  Result:= FAlimentosList;
end;

function TMoranguitoEmentasForm.CriancasValidasDS: TCollectionDataSourceUser;
begin
  if not Assigned(FCriancasValidasDS) then
    FCriancasValidasDS:= TCollectionDataSourceUser.Create(IntroducaoAlimentos.CriancasValidas,'Nome');
  Result:= FCriancasValidasDS;
end;

function TMoranguitoEmentasForm.CriancasInvalidasDS: TCollectionDataSourceUser;
begin
  if not Assigned(FCriancasInvalidasDS) then
    FCriancasInvalidasDS:= TCollectionDataSourceUser.Create(IntroducaoAlimentos.CriancasInvalidas,'Nome,AlimentosStr');
  Result:= FCriancasInvalidasDS;
end;

procedure TMoranguitoEmentasForm.ConfigureGridAnalise(AView: TcxGridTableView;
  ADS: TCollectionDataSourceUser);
var
  Column: TcxGridColumn;
begin
  Column:= ADS.GetColumnByFieldName(AView,'CriancaNome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Nome da Criança';
    Column.SortOrder:= soAscending;
  end;
  Column:= ADS.GetColumnByFieldName(AView,'Nome');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Nome da Criança';
    Column.SortOrder:= soAscending;
  end;
  Column:= ADS.GetColumnByFieldName(AView,'AlimentosStr');
  if Assigned(Column) then
  begin
    Column.Caption:= 'Alimentos não introduzidos';
    Column.Width:= 200;
  end;
  AView.OptionsView.ColumnAutoWidth:= True;
end;

procedure TMoranguitoEmentasForm.CheckListAlimentosEditValueChanged(Sender: TObject);
var
  i: Integer;
  AlimentosSeleccionados: TStringList;
  CheckItem: TcxCheckListBoxItem;
begin
  AlimentosSeleccionados:= TStringList.Create;
  try
    for i := 0 to CheckListAlimentos.Count - 1 do
    begin
      CheckItem:= CheckListAlimentos.Items[i];
      if CheckItem.Checked then
        AlimentosSeleccionados.Add((CheckItem.ItemObject as TWAlimentos).bf.AlimentoID);
    end;
    IntroducaoAlimentos.Load(AlimentosSeleccionados);
  finally
    AlimentosSeleccionados.Free;
  end;
  CriancasValidasDS.DataChanged;
  CriancasInvalidasDS.DataChanged;
end;

end.
