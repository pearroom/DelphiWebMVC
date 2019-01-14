unit wnMain;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.StdCtrls, uRouleMap,
  Web.HTTPProd, Web.ReqMulti, uConfig, ThSessionClear, Web.HTTPApp, Vcl.ExtCtrls,
  System.IniFiles, superobject, Vcl.ComCtrls, Vcl.Buttons, Vcl.Imaging.pngimage;

type
  TMain = class(TForm)
    TrayIcon1: TTrayIcon;
    Panel1: TPanel;
    ButtonOpenBrowser: TButton;
    btnClose: TButton;
    edtport: TEdit;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    grp1: TGroupBox;
    edtkey: TEdit;
    grp2: TGroupBox;
    grp3: TGroupBox;
    mmokeyvalue: TMemo;
    mmokey: TMemo;
    btnkey: TBitBtn;
    btn1: TBitBtn;
    stat1: TStatusBar;
    ts3: TTabSheet;
    pnl1: TPanel;
    img1: TImage;
    pnl2: TPanel;
    btnlogget: TButton;
    mmolog: TMemo;
    lbllog: TLabel;
    ts4: TTabSheet;
    btnreload: TButton;
    pnl3: TPanel;
    lbl1: TLabel;
    mmo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnkeyClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure stat1Click(Sender: TObject);
    procedure btnloggetClick(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure btnreloadClick(Sender: TObject);
  private
    procedure StartServer;
    procedure CloseServer;
    procedure setDataBase(jo: ISuperObject);

    { Private declarations }
  public

    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows, Winapi.ShellApi, command, wnDM, SessionList, DES, WebModule,
  uInterceptor, LogUnit, PackageManager;

procedure TMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then
  begin
    Application.Minimize;
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TMain.btn1Click(Sender: TObject);
begin
  if (Trim(edtkey.Text) = '') or (Trim(mmokeyvalue.Text) = '') then
  begin
    ShowMessage('秘钥与加密结果必填！');
    exit;
  end;
  ShowMessage(DeCryptStr(mmokeyvalue.Text, edtkey.Text));
end;

procedure TMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.btnkeyClick(Sender: TObject);
begin
  if (Trim(edtkey.Text) = '') or (Trim(mmokey.Text) = '') then
  begin
    ShowMessage('秘钥与加密内容必填！');
    exit;
  end;
  mmokeyvalue.Text := EnCryptStr(mmokey.Text, edtkey.Text);
end;

procedure TMain.btnloggetClick(Sender: TObject);
var
  msg: string;
begin
  lbllog.Caption := '日志加载中...';
  TThread.CreateAnonymousThread(
    procedure
    begin
      if not readlog(mmolog, msg) then
      begin
        mmolog.Lines.Add(msg);
        lbllog.Caption := '日志加载异常';
      end
      else
        lbllog.Caption := '日志加载完毕';
    end).Start;

end;

procedure TMain.btnreloadClick(Sender: TObject);
begin
  if open_package then
  begin
    try
      try
        btnreload.Enabled := false;
        Application.ProcessMessages;
        if _PackageManager <> nil then
        begin
          FreeAndNil(_PackageManager);
        end;
        _PackageManager := TPackageManager.Create;
        mmo1.Lines.Add('包重新装载完毕');
      except
        mmo1.Lines.Add('包装载异常,请检测日期');
      end;
    finally
      btnreload.Enabled := true;
      Application.ProcessMessages;
    end;

  end;
end;

procedure TMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin

  LURL := Format('http://localhost:%s', [edtport.Text]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMain.StartServer;
var
  LURL: string;
  FPort: string;
  jo: ISuperObject;
begin
  jo := OpenConfigFile();
  if jo <> nil then
  begin
    //服务启动在SynWebApp查询
    SessionName := '__guid_session';
    FPort := jo.O['Server'].S['Port'];
    edtport.Text := FPort;
    RouleMap := TRouleMap.Create;
    SessionListMap := TSessionList.Create;
    TThSessionClear.Create(false);
    if open_package then
      _PackageManager := TPackageManager.Create;
    _Interceptor := TInterceptor.Create;
    setDataBase(jo);
    log('服务启动');
  end;

end;

procedure TMain.stat1Click(Sender: TObject);
begin
  ShellExecute(0, nil, PChar('http://www.delphiwebmvc.com'), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMain.CloseServer;
begin
  if SessionListMap <> nil then
  begin
    FreeAndNil(SessionListMap);
    FreeAndNil(RouleMap);
    FreeAndNil(DM);
    FreeAndNil(_Interceptor);
    if open_package then
      FreeAndNil(_PackageManager);
  end;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseServer;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
  TrayIcon1.SetDefaultIcon;
  TrayIcon1.Visible := true;
  mmolog.Clear;
  edtport.ReadOnly := true;
  pgc1.ActivePageIndex := 0;
  StartServer;
end;

procedure TMain.pgc1Change(Sender: TObject);
begin
  if pgc1.ActivePageIndex = 2 then
  begin
    btnlogget.Click;
  end;
end;

procedure TMain.setDataBase(jo: ISuperObject);
var
  oParams: TStrings;
  jo1: ISuperObject;
  item: TSuperAvlEntry;
  value: string;
begin

  oParams := TStringList.Create;
  jo1 := jo.O[db_type];
  for item in jo1.AsObject do
  begin
    value := item.Name + '=' + item.Value.AsString;
    oParams.Add(value);
  end;
  DM := TDM.Create(Self);
  DM.DBManager.Active := false;
  DM.DBManager.DriverDefFileName := db_type;
   // DM.DBManager.ConnectionDefFileName := WebApplicationDirectory + config;
  DM.DBManager.AddConnectionDef(db_type, db_type, oParams);
  DM.DBManager.Active := true;
end;

procedure TMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE);
  Self.Show;
  Application.BringToFront;
end;

end.

