object MVCMain: TMVCMain
  Left = 271
  Top = 114
  Caption = 'MVCMain'
  ClientHeight = 405
  ClientWidth = 510
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
    Width = 510
    Height = 33
    Align = alTop
    TabOrder = 0
    object ButtonOpenBrowser: TButton
      Left = 149
      Top = 1
      Width = 287
      Height = 31
      Align = alClient
      Caption = 'Open Browser'
      TabOrder = 0
      OnClick = ButtonOpenBrowserClick
    end
    object btnClose: TButton
      Left = 436
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
    object btnStart: TButton
      Left = 76
      Top = 1
      Width = 73
      Height = 31
      Align = alLeft
      Caption = 'Start'
      TabOrder = 3
      OnClick = btnStartClick
    end
  end
  object pgc1: TPageControl
    Left = 0
    Top = 33
    Width = 510
    Height = 353
    ActivePage = ts3
    Align = alClient
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 1
    object ts3: TTabSheet
      Caption = 'Log'
      ImageIndex = 2
      object pnl2: TPanel
        Left = 0
        Top = 0
        Width = 502
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 0
        object lbllog: TLabel
          Left = 495
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
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = btnloggetClick
        end
      end
      object mmolog: TMemo
        Left = 0
        Top = 32
        Width = 502
        Height = 290
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object ts1: TTabSheet
      Caption = 'Cache'
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 502
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
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = btnseachClick
        end
        object btndel: TButton
          Left = 67
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = 'Remove'
          TabOrder = 1
          OnClick = btndelClick
        end
        object btndelall: TButton
          Left = 139
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = 'RemoveAll'
          TabOrder = 2
          OnClick = btndelallClick
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 32
        Width = 502
        Height = 290
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lstpage: TListBox
          Left = 0
          Top = 0
          Width = 502
          Height = 290
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object ts4: TTabSheet
      Caption = 'Session'
      ImageIndex = 3
      object pnl3: TPanel
        Left = 0
        Top = 0
        Width = 502
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
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = btnSessionClick
        end
        object btnRemoveSession: TButton
          Left = 67
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = 'Remove'
          TabOrder = 1
          OnClick = btnRemoveSessionClick
        end
        object btnRemoveSessionAll: TButton
          Left = 139
          Top = 0
          Width = 72
          Height = 28
          Align = alLeft
          Caption = 'RemoveAll'
          TabOrder = 2
          OnClick = btnRemoveSessionAllClick
        end
      end
      object lstSession: TListBox
        Left = 0
        Top = 32
        Width = 502
        Height = 290
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object ts5: TTabSheet
      Caption = 'Config'
      ImageIndex = 4
      object mmoConfig: TMemo
        Left = 0
        Top = 32
        Width = 502
        Height = 290
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object pnl4: TPanel
        Left = 0
        Top = 0
        Width = 502
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 1
        object lb1: TLabel
          Left = 495
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
          Caption = 'Save'
          TabOrder = 0
          OnClick = btnSaveConfigClick
        end
        object btnRefreshConfig: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = 'Refresh'
          TabOrder = 1
          OnClick = btnRefreshConfigClick
        end
      end
    end
    object ts6: TTabSheet
      Caption = 'MIME'
      ImageIndex = 5
      object mmoMIME: TMemo
        Left = 0
        Top = 32
        Width = 502
        Height = 290
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object pnl5: TPanel
        Left = 0
        Top = 0
        Width = 502
        Height = 32
        Align = alTop
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 1
        object lb2: TLabel
          Left = 495
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
          Caption = 'Save'
          TabOrder = 0
          OnClick = btnSaveMimeClick
        end
        object btnRefreshMime: TButton
          Left = 0
          Top = 0
          Width = 67
          Height = 28
          Align = alLeft
          Caption = 'Refresh'
          TabOrder = 1
          OnClick = btnRefreshMimeClick
        end
      end
    end
    object ts2: TTabSheet
      Caption = 'About'
      ImageIndex = 2
      object pnl1: TPanel
        Left = 0
        Top = 0
        Width = 502
        Height = 322
        Align = alClient
        Caption = 'pnl1'
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object img1: TImage
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 494
          Height = 314
          Align = alClient
          Center = True
          Picture.Data = {
            0954506E67496D61676589504E470D0A1A0A0000000D494844520000017F0000
            006A0802000000DB4AC6AC00000BED4944415478DAED9CDB61EA38108675AAC1
            E9E07461D2010DEC339400CFDB403AC074910EE2549335BEEA32238D2C87C986
            FF7B4A4096349AD1AFABF9F3F5F5650000E0E1FC81FA00005480FA00007480FA
            00007480FA00007480FA00007480FA00007480FA00007480FA00007480FA0000
            7480FA00007480FA00007480FA00007480FA00007480FA00007480FA00007480
            FA00007480FA00007448AB4F7BAA5E2E9FDD1FF5F5ABD9C79318B33B7EB4E78A
            4CD5ECFFBCDEE249E235E02BF08B69F6D5FB39AFBD24582E63D8A6B537F0DD18
            37D2B0714BD48FDEEC26984A4A5488AD7C5E4DA70CB8D444A0E437018760EE93
            76A0A8BD5266A62BF06CEA93D9EDB248AB4F4F71D9DAEAA31FBD45EA932ACF76
            E39C74CE405062C42EA71E215B84A564E5951253B79A4C2AC120946A21A8CF76
            24DA54361F282FE701CDA01DBD65EA1337DB19439694F2DA728D63D7C1CB64B3
            D030C27D9FB803C76FEBEBD5BCF26132E5F100F7FD1614D5C74E52D4F0FAEAA3
            1DBD6BD56757D7E676FB8CD9ED4E60AD8452F9A1CD12383E677A1541B6EB1C6B
            FC25381AB36767A78F74DF6F41597D4CC966475E39DFDB0CBAD1BB5A7D8ED77D
            F37AF94CAE06EBBABEDDBC0692C90F69D6FC68BCC1CB43C348D527628C1D1B86
            6D67D603FEFE03654CC47DF259AAA4A029D1F09DF7845DBAB45851A182E7820A
            94649E6A532A59ACB5A21520CA9136F284A33E5E7AA2C8B044DDE8759F16444E
            2088D1D560F7E5B97D09E559209871F1498965C14ED88CF0C49D2DCA0925D64D
            F4E3ECB696570A9D2BB76F9AD4A848DAD99A71D821EA7578238B65033B695DAC
            B9D922C416A54A581B6305BE4B343257D4EE78AC2E975B41893AD1BB643BCE51
            C4F6CEC11611B5FB577F4FD4E430253FB4555B688A1CE97D1FA656AEFB524261
            3F3C3BCFC9915C4F5299128F336BD1254AACCFC90FD95D3C3FD2A815B69B5186
            753CDC9223C7A2943FC5FB9289C6CFF01DBB5BC198C09D012DF938D5A02CD38C
            5ECFDEB4CB88F9183BC5EBBF68E938890B495C7C1EB4CB21BE6D487A869FE5B2
            ED59F1C9E479C6A3892A287401F50DBFDFB6440A27066BADE3A1D527CFA22C77
            C61286272A2B7D67F746762943F6F43039B5F9200C54696DCBFDCBA864CA5E67
            A5C9CCDA868FB9512A160F8C099BECE6C891DF75266C8C4D4A428D0F4739C6C6
            F91862CC212826B90E9FBF884E3FF9B08ADC7E10EC0AE45997D5E2D91671AC57
            9F42DFA5C657365862DBC149F5518CDEB5F6BACB4172081A3F64EB931EA8B841
            F6C7A94F68A4D0CFEC1093BA5E393D90D9BD058D9C67918997C954576A5D4683
            AFB06865CB8409A72C4B7D976F424C6FE5D9AB45EF5A7B630DEE884FCCE9CC57
            6C93FE5CF509549D19C5E9D6A317BC51B8082EEBBF16398122579F4CEBF26A9F
            6B1147F6BE8F7F8F7FA5EF4C7EEF8D999C216E5AD15B6CEF74B0EE9B289A8DC6
            E6CF9158FE81EAE3B513BB84708D2392417DCCFF4E7D565AF773D4472B7ACBED
            F5E5C7139F784C88D692D1E4DF48D63BEE4E3B0ABB23E5E5B23777B6539FEF59
            796D76497085FA6CBEF20AA6E285BE336AEAA315BD1BD8EBCA8F2F3E890AE5F5
            9E152717054295F70B1B5643D2970C0283CFEF44D3670A6C463C32AF183E74DF
            67B3E1E307ECFB84FB00A5BE2BDE07599FBD4EF46E61AFDDCF03F1C99B0FA71C
            5FFE8E580699BFEF338F051FD529790D93BF2C9EE7C08C0592EF08C90951EAC4
            35E5E2BC83B6FCC6CE3FF31294BCFE4D8B42DF959E0189B3E77DF8D8E84D4C27
            64F62EF2330862CE7CD859655669BFCB5465939B41B9BF2E36542DF9069CFB0A
            4A982C76EF2EF096F8BE4FD619BAF8AE48CAC5E14359D6A5DA5A7EDF27673012
            A80F77F9A9D077D1FB2F11B9DB407D54A2771B7BA72A1D8FEDC5131FC1845728
            BB09C7532D50B6BF90FDDB86CE9E1B1FBBC91F4D61AEEF5157CB1E7FD7B9507D
            B2ACE349BFE5F06D779D2DF745EE3EADF31D77A19C0BE90DD547237A597B3955
            8A0F3A449504CBED29C96EF7F999121FBF01BC66B22B523ABBCF561F69E156FD
            9964DC8B5AC12359EF79456E3D248A311BAA4F867511F85712377BCF2B416A2F
            215985D85B5743574816B9A5FA2844EFB290A3DF5393DACB4FA1249B7DF99A91
            8A902D0EE5F37FD759302FB3DB24912CB4517099982824D9207E41D1E0DC407D
            C4D6C5110E42D95927D54790DB4ADF51874AB142B7541F85E825CFDAD6D8CB2E
            B945470D52C39316E6E61003BF2A0F1E4CCEAB6EE05703F5010F06EA0346A03E
            E0C1407DC008D4073C18A80F1881FA800703F50123501FF060A03E6004EA0300
            D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001
            EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA03
            00D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D0
            01EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA
            0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300D001EA0300
            D001EA0300D001EA0300D001EA0300D0E129D5A7D9FF793B7C357BEBA3F654BD
            B467F7330F3789FF4097E7EB2D52667DE59EE48B3BFD6D9DFCCD94C73D8B4B75
            4DE6F15DF4E57F2612ED8E1FEDB972ECEDFEDC9BE6FEA9B605365DD39EAAA1AE
            CEDF767D1DD33B6B0E6F84BBEF3EAEECA6B937C1E18D68ABA96D9E9CA7549FA1
            2FB776047092E0769DB8FA588AE685ADFDA5232373659C481E6373EA096D4CD8
            EAA007870510D65B5D8C691E2A8BE041BF158866B49BC293FDC00B6BDC688A25
            CCB36AAA2415127381C10016A61E0DEFD4C753B064F33F0D4FAA3E86908B62F5
            91CC7D825943A734E7F685196F83189704EE37AA4F405A7D6C7388A944B10F8B
            D4C7755A7D3CB6176A4A37F8EE6E5BB35FE648F4DC07EA93C1F3AA8F0B3D68A7
            9717668A39D9DC67EA2E955D5C72B6CF566509F7B937EC8EC7EA7271D768C393
            CB6C7F2EB0FFE3BA6F5E872473767D3597BE383FB962EE9352E5D1907F8FED3F
            96CA8F8B32ABC37386D8F5AC570991A32A313B06170EFEE9460C6EEE63598C95
            579C67539F25888381CA8E91393AB69EFB2CC52D1243AACFDFD3905FFF1C3969
            58F4CEEE3F433D88D1DAFAC7569F39B1DDEB9DCFADF5D19A95975DE1EAFDCC75
            3ABBF756A7D6EC9B491DBBF20C6F0859FFEC8830C794FA586EBE4BBB61575EB3
            AF7CA761CA13F06CEA33402E10B6DAF7997A6BA71F53B439731F4FA3FAC94A13
            5F79C5E73EDEFAC3DE9B70D62573951DF5493FB9FC373CD8753DD1A4D01DE139
            1BA64496D29CDAEA660ECB0CD1440C09EBFF519D32AA67E66A75FFD2963953C2
            4587999557B8A2272BB36E9EF6CB80FA709F049FC7D567C0DB476587D056B6F2
            B2D4879FFBF82B8729EFEAC44DF95B67E5E53ED9E7D446D5C79DFB3815E3E73E
            F7233CD37D7C68B81D90D11ED3CD900EFBE634CCFFDE0E2243BCFACBA717F742
            4D7D6B2B67B4A0EC18F5663911E8AA767E0FA3C3D6A5BA97C23185652C71E8FA
            94407DB84F82CFC361ACF6C6E3CB675D0F916C6DF8F4A1E8AFF3FDA54D5A7DF8
            B94F4C7DE8BED86CA63EFE0791154BBFEA6AEDC5973773190CEFD4E7F4B73DBC
            7586773DB76F099336C4ABBF547D86EA5ECDABBF240AEC98D566F4CDE499A506
            C1015E9F04EA13E3C9D5A7D9DF037E5F38F77167E4DE99B2251F935A0DCFCE81
            5938F711AFBCEC274B565E11B1619AD16A9588360ED3A3B6990E8AF65563CE53
            C7E60C21EB2F8D83C1FD2679B3C1BABAE4A9CF32C0F84BA9C5C95879713CB3FA
            D8639E407D84F93A5D8A1CE4E63E3C264F9FB827CEBCECFD567FD779D9505D34
            92DE75F67635D2EAD39202123697DF088335C4B14F5F9DDD58C5EAD47E56E745
            B21843C8FAE7416C07336E0FD4A7DF99DA1FDB4B9838183138CD7F629E537D9C
            A8EDD9407DA8C393507DDC3ED287E8BEBA5C88DB86F76835B5B9DD24E738B33E
            F127EEC4C179DF0FBAC5E2EDE67C2F519FBE0983019C3E7137D69CEF5E99E520
            DACB60491C1C60F186CC3706D61E63AF541F7B494DF89E5AA55A532B9CB99B27
            559F398822C7E47658450F509673A7961CCD1DF5214F5D9913F76987247E965F
            34835F3B0AB3CF112781A76143D7DAB1F532A2962D0F6585FA50EE9E04737E09
            A3BE7A2F64ECDC5167CB7B97FF4F9E527DC008D6004013A8CF3303F5019A407D
            00003A407D00003A407D00003A407D00003A407D00003A407D00003A407D0000
            3A407D00003A407D00003A407D00003A407D00003A407D00003AFC07284B9086
            CDBB24B90000000049454E44AE426082}
          Transparent = True
          ExplicitLeft = 152
          ExplicitTop = 112
          ExplicitWidth = 105
          ExplicitHeight = 105
        end
      end
    end
  end
  object stat1: TStatusBar
    Left = 0
    Top = 386
    Width = 510
    Height = 19
    Cursor = crHandPoint
    Panels = <
      item
        Text = 'https://github.com/pearroom/DelphiWebMVC'
        Width = 370
      end
      item
        Text = #38656#20351#29992#31649#29702#21592#26435#38480#36816#34892
        Width = 50
      end>
    OnClick = stat1Click
  end
  object TrayIcon1: TTrayIcon
    OnClick = TrayIcon1Click
    Left = 104
    Top = 160
  end
end
