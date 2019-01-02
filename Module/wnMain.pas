unit wnMain;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.StdCtrls, uRouleMap,
  Web.HTTPProd, Web.ReqMulti, uConfig, ThSessionClear, SynHTTPWebBrokerBridge,
  Web.HTTPApp, Vcl.ExtCtrls, System.IniFiles, superobject, Vcl.ComCtrls, Vcl.Buttons;

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
    mmolog: TMemo;
    grp1: TGroupBox;
    edtkey: TEdit;
    grp2: TGroupBox;
    grp3: TGroupBox;
    mmokeyvalue: TMemo;
    mmokey: TMemo;
    btnkey: TBitBtn;
    btn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnkeyClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    FServer: TSynHTTPWebBrokerBridge;
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
  uInterceptor;

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
    SessionName := '__guid_session';
    FPort := jo.O['Server'].S['Port'];
    edtport.Text := FPort;
    FServer := TSynHTTPWebBrokerBridge.Create(Self);
    RouleMap := TRouleMap.Create;
    SessionListMap := TSessionList.Create;
    TThSessionClear.Create(false);
    _Interceptor := TInterceptor.Create;
    setDataBase(jo);
  end;

end;

procedure TMain.CloseServer;
begin
  if SessionListMap <> nil then
  begin
    FreeAndNil(SessionListMap);
    FreeAndNil(RouleMap);
    FreeAndNil(DM);
    FreeAndNil(_Interceptor);
    FServer.Free;
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

