object MVCMain: TMVCMain
  Left = 271
  Top = 114
  Caption = 'MVCMain'
  ClientHeight = 420
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 512
    Height = 33
    Align = alTop
    TabOrder = 0
    object ButtonOpenBrowser: TButton
      Left = 149
      Top = 1
      Width = 216
      Height = 31
      Align = alClient
      Caption = #25171#24320#27983#35272#22120'(&W)'
      TabOrder = 0
      OnClick = ButtonOpenBrowserClick
    end
    object btnClose: TButton
      Left = 438
      Top = 1
      Width = 73
      Height = 31
      Align = alRight
      Caption = #36864#20986'(&Q)'
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
    object btnStart: TButton
      Left = 76
      Top = 1
      Width = 73
      Height = 31
      Align = alLeft
      Caption = #21551#21160
      TabOrder = 3
      OnClick = btnStartClick
    end
    object btnSet: TButton
      Left = 365
      Top = 1
      Width = 73
      Height = 31
      Align = alRight
      Caption = #39640#32423#35774#32622'(&E)'
      TabOrder = 4
      OnClick = btnSetClick
    end
  end
  object pgc1: TPageControl
    Left = 0
    Top = 33
    Width = 512
    Height = 368
    ActivePage = ts2
    Align = alClient
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 1
    object ts3: TTabSheet
      Caption = #26085#24535
      ImageIndex = 2
      object pnl2: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 0
        object lbllog: TLabel
          Left = 497
          Top = 0
          Width = 3
          Height = 28
          Align = alRight
          Layout = tlCenter
          ExplicitHeight = 13
        end
        object btnlogget: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 0
          OnClick = btnloggetClick
        end
      end
      object mmolog: TMemo
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object ts1: TTabSheet
      Caption = #39029#38754#32531#23384
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 0
        object btnseach: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 0
          OnClick = btnseachClick
        end
        object btndel: TButton
          Left = 67
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500
          TabOrder = 1
          OnClick = btndelClick
        end
        object btndelall: TButton
          Left = 139
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500#20840#37096
          TabOrder = 2
          OnClick = btndelallClick
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lstpage: TListBox
          Left = 0
          Top = 0
          Width = 504
          Height = 305
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object SQL: TTabSheet
      Caption = 'SQL'#25991#20214#32531#23384
      ImageIndex = 6
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 0
        object Button1: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 0
          OnClick = Button1Click
        end
        object Button2: TButton
          Left = 67
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500
          TabOrder = 1
          OnClick = Button2Click
        end
        object Button3: TButton
          Left = 139
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500#20840#37096
          TabOrder = 2
          OnClick = Button3Click
        end
      end
      object lstsql: TListBox
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object ts4: TTabSheet
      Caption = 'Session'#31649#29702
      ImageIndex = 3
      object pnl3: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 0
        object btnSession: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 0
          OnClick = btnSessionClick
        end
        object btnRemoveSession: TButton
          Left = 67
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500
          TabOrder = 1
          OnClick = btnRemoveSessionClick
        end
        object btnRemoveSessionAll: TButton
          Left = 139
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = #31227#38500#20840#37096
          TabOrder = 2
          OnClick = btnRemoveSessionAllClick
        end
      end
      object lstSession: TListBox
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object ts5: TTabSheet
      Caption = 'Config'#37197#32622
      ImageIndex = 4
      object mmoConfig: TMemo
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object pnl4: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 1
        object lb1: TLabel
          Left = 497
          Top = 0
          Width = 3
          Height = 28
          Align = alRight
          Layout = tlCenter
          ExplicitHeight = 13
        end
        object btnSaveConfig: TButton
          Left = 67
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #20445#23384
          TabOrder = 0
          OnClick = btnSaveConfigClick
        end
        object btnRefreshConfig: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 1
          OnClick = btnRefreshConfigClick
        end
      end
    end
    object ts6: TTabSheet
      Caption = 'MIME'#37197#32622
      ImageIndex = 5
      object mmoMIME: TMemo
        Left = 0
        Top = 32
        Width = 504
        Height = 305
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object pnl5: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 1
        object lb2: TLabel
          Left = 497
          Top = 0
          Width = 3
          Height = 28
          Align = alRight
          Layout = tlCenter
          ExplicitHeight = 13
        end
        object btnSaveMime: TButton
          Left = 67
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #20445#23384
          TabOrder = 0
          OnClick = btnSaveMimeClick
        end
        object btnRefreshMime: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = #21047#26032
          TabOrder = 1
          OnClick = btnRefreshMimeClick
        end
      end
    end
    object ts2: TTabSheet
      Caption = #24320#21457#25991#26723
      ImageIndex = 2
      object pnl1: TPanel
        Left = 0
        Top = 0
        Width = 504
        Height = 337
        Align = alClient
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        DesignSize = (
          504
          337)
        object pnl6: TPanel
          Left = 86
          Top = 23
          Width = 328
          Height = 274
          Anchors = []
          BevelOuter = bvNone
          TabOrder = 0
          object Image1: TImage
            Left = 113
            Top = 72
            Width = 87
            Height = 101
            AutoSize = True
            Picture.Data = {
              0954506E67496D61676589504E470D0A1A0A0000000D49484452000000570000
              00650806000000387A7FCA0000000473424954080808087C0864880000000970
              48597300000B1200000B1201D2DD7EFC00000016744558744372656174696F6E
              2054696D650030322F31382F3232ADAEF4B80000001C74455874536F66747761
              72650041646F62652046697265776F726B7320435336E8BCB28C000005034944
              415478DAED9C8B75D340104527159054805301A202940A800A1015103A301560
              2A40548053014A053815A054405201EC78FDFF4ADAF7B4923DEF1CC939F9484F
              37ABD9D9D16A2FC444D3456C03A72C834B94C125CAE01265708932B844195CA2
              0C2E51069728834B94C125CAE01265708932B844195CA20EC34DD281DBE7B14D
              0255CC3ECBD9369149F1C43AD931B86AE64D6C22643D8A42F6E00B077B823AF0
              7EB8499AB9FDF7D8571E410A7BECB691035D861C6837DC24BD147FDBBC887DA5
              9175EFB6A1835C34F9E37D70476EFF29F69575488D206FC34DD2D4ED7FC5BE9A
              8EEACE6D59D54E70175C0DE8AF625F4587F5ECB677555AF13ADC24BD75FBAFB1
              DDF7441F1DE0FCD02F2CE15A27D6443F1CE06CDF0F57E16AFAF136B6DB1E6A6F
              0BF670AD130BD57B0778BCF9CD39DCD2ED5FC676D863692737D8CC222E1CD844
              B4F73B0DA5B3CF1843F6ADF87BBA55315F744A67DB8796CE7ABD3A643E5DB8AB
              F299D0ED6C6366436BADF73CE0CEE521E7C2CD8AAEE6B1F7BCE0CE95A4B9F042
              C522353B4FB82A5E5EBF080D7CB83E870E15FE89016F44FAE0BC6A0646869BA4
              9AE2FD041CE93AB470BDC75F268C07029362CA950D3797F0D8B66809248F7A47
              A05BEFB431B0E196123EF2FBEC8C8E881E73C1776E375A92E4C1F523BFDF8023
              7142C2D2272A74AD8A0E17F1A8E8D1991CD03C7A9F7AFC3FE0A3D2E196121E12
              BE3993B7348F4BAFFFC04724C2C5B586D7C8790407FCA21F6D4D7DB3E0221E17
              3D3B8397147FDB7E0B4156D2A8A918A6251C7C8402F65B080EEEA29FC0C3C585
              849DD57D8AB070EF9CEF697D9C013793F0514F7B21C17B46C6DC2FCEFB50BF60
              C045144416FFFD5684CD16169D3016AE2F86FC051CE9E89C00A067D46047B576
              C7A1E1668229845C31E7CD6E78464E84213E89C08CD3DB0E09C8BAEE5A278C86
              8BA830710B35EB7E51614CB53554C7C1ED7AED76B7E74C70F5DC45963017126E
              2E5DAFDD6E7B2E0493DFEE991482335A4AD76BB7EB7E9159C256AB5561E0E28C
              B653A8F19E73C114C977B65A150A6E3F6AB74BBF7A1E540D7767AB55A1E096D2
              97DAADF79B0BB9D5AAC2E1E25AC14DD3B76622F9551D1C4922E0F6AD768B1A34
              DC3BCFE9A15F40C0ED4FED16978B6B38488EE5E36170FB54BBC5CEB0A954580A
              859B09628433213E285D7A458583CAB58F50B8FDA8DDE22A5F0FA293A91BBFE4
              57DD703F6AB7D8389BD619E484C0CDA4EBB55B3F722C0413676BA78A21707309
              4FC48FA63301FE90601BDD5D2170BB5BBBF57382C7007FAAC661AB19DC2ED76E
              B135DAA0FEA0295C3D61F76AB7D87522823BDAA6704B092FD4ECAD2635F03310
              1F0610730F2ABFF27F4CF5E176AD76EB73D8A160E2ABE6B119AAA6DC046E376A
              B7FE9FAC5E50D3907E88BE04084C0B9BC02D2566EDD60F5E86828BADCFE2D7AF
              81672DF5E0C62CD4705E31D5858132D6D3E6BA70DBAFDDFADB5FCF8B7C2984D6
              5A5755176E3BB55B7F87682E9D01CEB77D7E706CDDA7EA709921C18FA8F4F8E9
              6C632CAC11B4005B13D5819B0966E4A3E9CEBCD5B4B1E844EB50E7AA03B76F0B
              0CE9026BA31850E7AA06173B618D29EDA872012C72895055B899747B45526DA5
              E3D6264C575455B86ABAAD7562AACA03F550DB99285D5355E132DEECAE2BED08
              0B592E22DC49A0AB3A0E97F3E2F131E902C1A578907E55E61EC0DC5415B8B9E0
              4747AB55A762F6A9DF7B8AD9BBA375BE6BDCB420834B94C125CAE01265708932
              B844195CA20C2E51069728834B94C125CAE01265708932B844195CA20C2E51FF
              01D317EC75AD75D3970000000049454E44AE426082}
          end
          object Label1: TLabel
            Left = 41
            Top = -8
            Width = 235
            Height = 42
            Caption = 'DelphiWebMVC'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -35
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label2: TLabel
            Left = 72
            Top = 39
            Width = 164
            Height = 19
            Caption = #25216#26415'QQ'#32676': 685072623'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object btn1: TBitBtn
            Left = 113
            Top = 171
            Width = 88
            Height = 35
            Caption = #24320#21457#25991#26723
            TabOrder = 0
            OnClick = btn1Click
          end
          object BitBtn1: TBitBtn
            Left = 113
            Top = 212
            Width = 88
            Height = 35
            Caption = #24320#21457#35270#39057
            TabOrder = 1
            OnClick = BitBtn1Click
          end
        end
      end
    end
  end
  object stat1: TStatusBar
    Left = 0
    Top = 401
    Width = 512
    Height = 19
    Cursor = crHandPoint
    Panels = <
      item
        Text = 'https://gitee.com/pearroom/DelphiWebMVC'
        Width = 300
      end
      item
        Text = #38656#20351#29992#31649#29702#21592#26435#38480#36816#34892
        Width = 50
      end>
    OnClick = stat1Click
  end
  object TrayIcon1: TTrayIcon
    OnClick = TrayIcon1Click
    Left = 480
    Top = 368
  end
end
