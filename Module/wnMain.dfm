object Main: TMain
  Left = 271
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 320
  ClientWidth = 337
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
    Width = 337
    Height = 33
    Align = alTop
    TabOrder = 0
    object ButtonOpenBrowser: TButton
      Left = 76
      Top = 1
      Width = 187
      Height = 31
      Align = alClient
      Caption = 'Open Browser'
      TabOrder = 0
      OnClick = ButtonOpenBrowserClick
    end
    object btn1: TButton
      Left = 263
      Top = 1
      Width = 73
      Height = 31
      Align = alRight
      Caption = 'Close'
      TabOrder = 1
      OnClick = btn1Click
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
  object grp1: TGroupBox
    Left = 0
    Top = 33
    Width = 337
    Height = 287
    Align = alClient
    Caption = #26085#24535
    TabOrder = 1
    object mmolog: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 327
      Height = 264
      Align = alClient
      Lines.Strings = (
        'mmolog')
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object TrayIcon1: TTrayIcon
    OnClick = TrayIcon1Click
    Left = 192
    Top = 200
  end
end
