object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Batch JPEG Files resizer'
  ClientHeight = 326
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 329
    Height = 326
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object GroupBoxsourcefolder: TGroupBox
      Left = 0
      Top = 110
      Width = 329
      Height = 67
      Align = alTop
      Caption = 'Source Folder'
      TabOrder = 1
      object EditSource: TEdit
        Left = 5
        Top = 26
        Width = 289
        Height = 21
        TabOrder = 0
      end
      object ButtonsourceExplore: TButton
        Left = 298
        Top = 24
        Width = 27
        Height = 25
        Hint = 'Explorer'
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = ButtonsourceExploreClick
      end
    end
    object GroupBoxdestfolder: TGroupBox
      Left = 0
      Top = 177
      Width = 329
      Height = 58
      Align = alTop
      Caption = 'Destination Folder'
      TabOrder = 2
      object EditDest: TEdit
        Left = 5
        Top = 26
        Width = 289
        Height = 21
        TabOrder = 0
      end
      object ButtondestExplore: TButton
        Left = 298
        Top = 24
        Width = 27
        Height = 25
        Hint = 'Explorer'
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = ButtondestExploreClick
      end
    end
    object GroupBox6: TGroupBox
      Left = 0
      Top = 235
      Width = 329
      Height = 91
      Align = alClient
      Caption = 'Execution'
      TabOrder = 3
      object Gauge1: TGauge
        Left = 5
        Top = 59
        Width = 241
        Height = 18
        Progress = 0
      end
      object Buttontrt: TButton
        Left = 250
        Top = 54
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 0
        OnClick = ButtontrtClick
      end
      object StaticText1: TStaticText
        Left = 16
        Top = 20
        Width = 59
        Height = 17
        Caption = 'StaticText1'
        TabOrder = 1
      end
    end
    object RadioGroupLanguage: TRadioGroup
      Left = 0
      Top = 0
      Width = 329
      Height = 110
      Align = alTop
      Caption = 'Language'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'English'
        'French')
      TabOrder = 0
      OnClick = RadioGroupLanguageClick
    end
  end
  object GroupBoxRules: TGroupBox
    Left = 329
    Top = 0
    Width = 467
    Height = 326
    Align = alClient
    Caption = 'Rules'
    TabOrder = 1
    object GroupBoxHeight: TGroupBox
      Left = 2
      Top = 209
      Width = 463
      Height = 115
      Align = alBottom
      Caption = 'Height'
      TabOrder = 2
      object LabelNewHeight: TLabel
        Left = 4
        Top = 31
        Width = 55
        Height = 13
        Caption = 'New Height'
      end
      object EditNewHeight: TEdit
        Left = 86
        Top = 28
        Width = 75
        Height = 21
        TabOrder = 0
      end
      object CheckBoxUnchangeHeight: TCheckBox
        Left = 4
        Top = 53
        Width = 160
        Height = 17
        Caption = 'Keep Unchanged'
        TabOrder = 1
        OnClick = CheckBoxUnchangeHeightClick
      end
      object RadioGroupBiggerHeight: TRadioGroup
        Left = 169
        Top = 15
        Width = 146
        Height = 98
        Align = alRight
        Caption = 'If bigger or equal'
        ItemIndex = 1
        Items.Strings = (
          'Keep Unchanged'
          'Resize')
        TabOrder = 2
      end
      object RadioGroupsmallerHeight: TRadioGroup
        Left = 315
        Top = 15
        Width = 146
        Height = 98
        Align = alRight
        Caption = 'If smaller'
        ItemIndex = 1
        Items.Strings = (
          'Keep Unchanged'
          'Resize')
        TabOrder = 3
      end
    end
    object GroupBoxWidth: TGroupBox
      Left = 2
      Top = 110
      Width = 463
      Height = 99
      Align = alBottom
      Caption = 'Width'
      TabOrder = 1
      object Labelnewwidth: TLabel
        Left = 4
        Top = 36
        Width = 52
        Height = 13
        Caption = 'New Width'
      end
      object EditNewWidth: TEdit
        Left = 86
        Top = 33
        Width = 76
        Height = 21
        TabOrder = 0
      end
      object RadioGroupSmallerWidth: TRadioGroup
        Left = 315
        Top = 15
        Width = 146
        Height = 82
        Align = alRight
        Caption = 'If smaller'
        ItemIndex = 1
        Items.Strings = (
          'Keep Unchanged'
          'Resize')
        TabOrder = 3
      end
      object CheckBoxUnchangeWidth: TCheckBox
        Left = 4
        Top = 60
        Width = 160
        Height = 17
        Caption = 'Keep Unchanged'
        TabOrder = 1
        OnClick = CheckBoxUnchangeWidthClick
      end
      object RadioGroupBiggerWidth: TRadioGroup
        Left = 169
        Top = 15
        Width = 146
        Height = 82
        Align = alRight
        Caption = 'If bigger or equal'
        ItemIndex = 1
        Items.Strings = (
          'Keep Unchanged'
          'Resize')
        TabOrder = 2
      end
    end
    object RadioGroupProportion: TRadioGroup
      Left = 2
      Top = 15
      Width = 463
      Height = 95
      Align = alClient
      Caption = 'Proportionnal Master'
      ItemIndex = 0
      Items.Strings = (
        'None (force resize both)'
        'Width'
        'Height')
      TabOrder = 0
      OnClick = RadioGroupProportionClick
    end
  end
  object FolderDialog1: TFolderDialog
    DialogX = 0
    DialogY = 0
    Version = '1.1.1.0'
    Left = 320
    Top = 64
  end
end
