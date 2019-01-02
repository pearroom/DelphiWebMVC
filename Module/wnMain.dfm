object Main: TMain
  Left = 271
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 414
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 421
    Height = 33
    Align = alTop
    TabOrder = 0
    object ButtonOpenBrowser: TButton
      Left = 76
      Top = 1
      Width = 271
      Height = 31
      Align = alClient
      Caption = 'Open Browser'
      TabOrder = 0
      OnClick = ButtonOpenBrowserClick
    end
    object btnClose: TButton
      Left = 347
      Top = 1
      Width = 73
      Height = 31
      Align = alRight
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
    object edtport: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 69
      Height = 25
      Align = alLeft
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Text = '0'
      ExplicitHeight = 27
    end
  end
  object pgc1: TPageControl
    Left = 0
    Top = 33
    Width = 421
    Height = 381
    ActivePage = ts1
    Align = alClient
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 1
    object ts1: TTabSheet
      Caption = #26085#24535
      object mmolog: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 407
        Height = 344
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object ts2: TTabSheet
      Caption = #21152#23494#24037#20855
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 329
      ExplicitHeight = 256
      object grp1: TGroupBox
        Left = 0
        Top = 0
        Width = 413
        Height = 49
        Align = alTop
        Caption = #31192#38053
        TabOrder = 0
        ExplicitWidth = 329
        object edtkey: TEdit
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 253
          Height = 26
          Align = alClient
          TabOrder = 0
          ExplicitWidth = 324
        end
        object btnkey: TBitBtn
          Left = 261
          Top = 15
          Width = 75
          Height = 32
          Align = alRight
          Caption = #21152#23494
          TabOrder = 1
          OnClick = btnkeyClick
          ExplicitLeft = 344
          ExplicitTop = 80
          ExplicitHeight = 25
        end
        object btn1: TBitBtn
          Left = 336
          Top = 15
          Width = 75
          Height = 32
          Align = alRight
          Caption = #35299#23494
          TabOrder = 2
          OnClick = btn1Click
          ExplicitLeft = 357
          ExplicitTop = 23
        end
      end
      object grp2: TGroupBox
        Left = 0
        Top = 185
        Width = 413
        Height = 165
        Align = alClient
        Caption = #21152#23494#32467#26524
        TabOrder = 1
        ExplicitLeft = 112
        ExplicitTop = 120
        ExplicitWidth = 185
        ExplicitHeight = 105
        object mmokeyvalue: TMemo
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 403
          Height = 142
          Align = alClient
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitHeight = 113
        end
      end
      object grp3: TGroupBox
        Left = 0
        Top = 49
        Width = 413
        Height = 136
        Align = alTop
        Caption = #21152#23494#20869#23481
        TabOrder = 2
        object mmokey: TMemo
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 403
          Height = 113
          Align = alClient
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitLeft = 10
          ExplicitTop = 23
        end
      end
    end
  end
  object TrayIcon1: TTrayIcon
    OnClick = TrayIcon1Click
    Left = 112
    Top = 136
  end
end
