object MoranguitoAnaliseForm: TMoranguitoAnaliseForm
  Left = 0
  Top = 0
  Caption = 'Registo de Introdu'#231#227'o de Alimentos'
  ClientHeight = 366
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 366
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Grid: TcxGrid
      Left = 0
      Top = 0
      Width = 692
      Height = 366
      Align = alClient
      TabOrder = 0
      object GridView: TcxGridTableView
        NavigatorButtons.ConfirmDelete = False
        OnEditValueChanged = GridViewEditValueChanged
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.DataRowHeight = 35
        OptionsView.HeaderHeight = 35
      end
      object GridLevel: TcxGridLevel
        GridView = GridView
      end
    end
  end
  object EditRepository: TcxEditRepository
    Left = 16
    Top = 48
    object EditRepositoryTextItem: TcxEditRepositoryTextItem
      Properties.Alignment.Vert = taVCenter
      Properties.ReadOnly = True
    end
  end
  object StyleRepository: TcxStyleRepository
    Left = 48
    Top = 48
    PixelsPerInch = 96
    object StyleAlimento: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
  end
end
