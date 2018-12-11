object Main: TMain
  Left = 271
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 385
  ClientWidth = 425
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 425
    Height = 45
    Align = alTop
    TabOrder = 0
    object ButtonOpenBrowser: TButton
      Left = 1
      Top = 1
      Width = 350
      Height = 43
      Align = alClient
      Caption = 'Open Browser'
      TabOrder = 0
      OnClick = ButtonOpenBrowserClick
    end
    object btn1: TButton
      Left = 351
      Top = 1
      Width = 73
      Height = 43
      Align = alRight
      Caption = 'Close'
      TabOrder = 1
      OnClick = btn1Click
    end
  end
  object grp1: TGroupBox
    Left = 0
    Top = 45
    Width = 425
    Height = 340
    Align = alClient
    Caption = #26085#24535
    TabOrder = 1
    object mmolog: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 415
      Height = 317
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
