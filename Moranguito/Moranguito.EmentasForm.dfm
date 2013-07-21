object MoranguitoEmentasForm: TMoranguitoEmentasForm
  Left = 0
  Top = 0
  Caption = 'Ementas'
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
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 692
      Height = 129
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object gbAlimentos: TGroupBox
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 680
        Height = 117
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        Align = alClient
        Caption = 'Alimentos'
        TabOrder = 0
        object CheckListAlimentos: TcxCheckListBox
          AlignWithMargins = True
          Left = 8
          Top = 21
          Width = 664
          Height = 88
          Margins.Left = 6
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Align = alClient
          Columns = 4
          Items = <>
          TabOrder = 0
          OnEditValueChanged = CheckListAlimentosEditValueChanged
        end
      end
    end
    object GridPanel: TGridPanel
      Left = 0
      Top = 129
      Width = 692
      Height = 237
      Align = alClient
      BevelOuter = bvNone
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = pnlValidos
          Row = 0
        end
        item
          Column = 0
          Control = GridValidos
          Row = 1
        end
        item
          Column = 1
          Control = pnlInvalidos
          Row = 0
        end
        item
          Column = 1
          Control = GridInvalidos
          Row = 1
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 30.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 1
      object pnlValidos: TPanel
        Left = 0
        Top = 0
        Width = 346
        Height = 30
        Align = alClient
        Caption = 'Alimento Introduzido'
        Color = 8454016
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16384
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
      end
      object GridValidos: TcxGrid
        Left = 0
        Top = 30
        Width = 346
        Height = 207
        Align = alClient
        TabOrder = 1
        object GridValidosView: TcxGridTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
        end
        object GridValidosLevel: TcxGridLevel
          GridView = GridValidosView
        end
      end
      object pnlInvalidos: TPanel
        Left = 346
        Top = 0
        Width = 346
        Height = 30
        Align = alClient
        Caption = 'Alimento N'#227'o Introduzido'
        Color = 8421631
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
      end
      object GridInvalidos: TcxGrid
        Left = 346
        Top = 30
        Width = 346
        Height = 207
        Align = alClient
        TabOrder = 3
        object GridInvalidosView: TcxGridTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
        end
        object GridInvalidosLevel: TcxGridLevel
          GridView = GridInvalidosView
        end
      end
    end
  end
end
