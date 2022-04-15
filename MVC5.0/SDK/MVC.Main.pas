{ ******************************************************* }
{ }
{ DelphiWebMVC 5.0 }
{ E-Mail:pearroom@yeah.net }
{ 版权所有 (C) 2022-2 苏兴迎(PRSoft) }
{ }
{ ******************************************************* }
unit MVC.Main;

interface

uses
  Winapi.Windows, Winapi.ShellApi, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Imaging.pngimage,
  MVC.TplUnit, MVC.LogUnit, MVC.Config, MVC.Session, MVC.JSON, MVC.App,
  Vcl.Buttons;

type
  TMVCMain = class(TForm)
    TrayIcon1: TTrayIcon;
    Panel1: TPanel;
    ButtonOpenBrowser: TButton;
    btnClose: TButton;
    edtport: TEdit;
    pgc1: TPageControl;
    stat1: TStatusBar;
    ts3: TTabSheet;
    pnl2: TPanel;
    btnlogget: TButton;
    lbllog: TLabel;
    ts1: TTabSheet;
    ts2: TTabSheet;
    pnl1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnseach: TButton;
    btndel: TButton;
    lstpage: TListBox;
    btndelall: TButton;
    ts4: TTabSheet;
    pnl3: TPanel;
    btnSession: TButton;
    lstSession: TListBox;
    mmolog: TMemo;
    btnRemoveSession: TButton;
    btnRemoveSessionAll: TButton;
    ts5: TTabSheet;
    ts6: TTabSheet;
    mmoConfig: TMemo;
    pnl4: TPanel;
    lb1: TLabel;
    btnSaveConfig: TButton;
    mmoMIME: TMemo;
    pnl5: TPanel;
    lb2: TLabel;
    btnSaveMime: TButton;
    btnStart: TButton;
    btnRefreshMime: TButton;
    btnRefreshConfig: TButton;
    btnSet: TButton;
    SQL: TTabSheet;
    Panel4: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    lstsql: TListBox;
    pnl6: TPanel;
    Image1: TImage;
    btn1: TBitBtn;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure stat1Click(Sender: TObject);
    procedure btnloggetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnseachClick(Sender: TObject);
    procedure btndelClick(Sender: TObject);
    procedure btndelallClick(Sender: TObject);
    procedure btnSessionClick(Sender: TObject);
    procedure btnRemoveSessionClick(Sender: TObject);
    procedure btnRemoveSessionAllClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnRefreshConfigClick(Sender: TObject);
    procedure btnRefreshMimeClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnSaveMimeClick(Sender: TObject);
    procedure btnSetClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure LinkLabel1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BitBtn1Click(Sender: TObject);
  private
    function readlog(var str: TMemo; var Msg: string): boolean;
    procedure OpenDelphiWebMVC;
    procedure OpenURL(url: string);
   { Private declarations }

  end;

var
  MVCMain: TMVCMain;

implementation

{$R *.dfm}

procedure TMVCMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then
  begin
    Application.Minimize;
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TMVCMain.BitBtn1Click(Sender: TObject);
begin
  OpenURL('https://space.bilibili.com/18184783');
end;

procedure TMVCMain.btn1Click(Sender: TObject);
begin
  OpenURL('https://www.yuque.com/suxingying/mvc5.0/vt954m');
end;

procedure TMVCMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TMVCMain.readlog(var str: TMemo; var Msg: string): boolean;
var
  logfile: string;
begin

  if Config.open_log then
  begin
    logfile := ExtractFileDir(Application.ExeName) + '\log\';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';
    if FileExists(logfile) then
    begin
      str.Lines.LoadFromFile(logfile);
      Result := true;
    end
    else
    begin
      Msg := logfile + '未找到日志文件';
      Result := false;
    end;
  end
  else
  begin
    Msg := '日志功能未开启';
    Result := false;
  end;
end;

procedure TMVCMain.btndelallClick(Sender: TObject);
begin
  if lstpage.Count > 0 then
  begin
    PageCache.PageList.Clear;
    lstpage.Clear;
  end;
end;

procedure TMVCMain.btndelClick(Sender: TObject);
begin
  if lstpage.ItemIndex > -1 then
  begin
    PageCache.PageList.Remove(lstpage.Items.Strings[lstpage.ItemIndex]);
    lstpage.DeleteSelected;
  end;
end;

procedure TMVCMain.btnloggetClick(Sender: TObject);
var
  Msg: string;
begin
  lbllog.Caption := '加载中...';
  TThread.CreateAnonymousThread(
    procedure
    begin
      if not readlog(mmolog, Msg) then
      begin
        mmolog.Lines.Add(Msg);
        lbllog.Caption := '加载失败';
      end
      else
        lbllog.Caption := '加载完毕';
    end).Start;
end;

procedure TMVCMain.btnRefreshConfigClick(Sender: TObject);
begin
  mmoConfig.Lines.LoadFromFile(Config.config_path, TEncoding.UTF8);
end;

procedure TMVCMain.btnRefreshMimeClick(Sender: TObject);
begin
  mmoMIME.Lines.LoadFromFile(Config.mime_path);
end;

procedure TMVCMain.btnRemoveSessionAllClick(Sender: TObject);
begin
  if lstSession.Count > 0 then
  begin
    SessionPool.delAllSessioin;
    lstSession.Clear;
  end;
end;

procedure TMVCMain.btnRemoveSessionClick(Sender: TObject);
var
  value, key: string;
  arr: TArray<string>;
begin
  if lstSession.ItemIndex > -1 then
  begin
    value := lstSession.Items.Strings[lstSession.ItemIndex];
    arr := value.Split([' ']);
    key := arr[1].Substring(4);
    SessionPool.deleteSession(key);
    lstSession.DeleteSelected;
  end;
end;

procedure TMVCMain.btnSaveConfigClick(Sender: TObject);
var
  _ConfigJSON: IJObject;
begin
  mmoConfig.Lines.SaveToFile(Config.config_path, TEncoding.UTF8);
  _ConfigJSON := Config.read_config;
  if _ConfigJSON <> nil then
  begin
    if (_ConfigJSON.O.GetValue('AppTitle') <> nil) and (_ConfigJSON.O.GetValue('AppTitle').value <> '') then
    begin
      Application.Title := _ConfigJSON.O.GetValue('AppTitle').value;
      Caption := Application.Title;
    end;
  end;
end;

procedure TMVCMain.btnSaveMimeClick(Sender: TObject);
begin
  mmoMIME.Lines.SaveToFile(Config.mime_path, TEncoding.UTF8);
end;

procedure TMVCMain.btnseachClick(Sender: TObject);
var
  key: string;
begin
  for key in PageCache.PageList.Keys do
  begin
    if lstpage.Items.IndexOf(key) < 0 then
      lstpage.Items.Add(key);
  end;
  lstpage.Sorted := true;
end;

procedure TMVCMain.btnSessionClick(Sender: TObject);
var
  sList: TStringList;
begin
  sList := TStringList.Create;
  SessionPool.getAllSession(sList);
  lstSession.Items := sList;
  sList.Free;
end;

procedure TMVCMain.btnSetClick(Sender: TObject);
begin
  Application.MessageBox('敬请期待！！！', '提示', MB_OK);
end;

procedure TMVCMain.btnStartClick(Sender: TObject);
begin
  if btnStart.Caption = '启动' then
  begin

    edtport.Text := StartServer;
    if edtport.Text = '-1' then
    begin
      mmolog.Lines.Add('config.json配置文件错误');
      ButtonOpenBrowser.Enabled := false;
    end
    else
    begin
      btnStart.Caption := '停止';
    end;
  end
  else
  begin
    CloseServer;
    edtport.Text := '0';
    btnStart.Caption := '启动';
  end;
end;

procedure TMVCMain.Button1Click(Sender: TObject);
var
  key: string;
begin
  for key in SQLCache.SQLList.Keys do
  begin
    if lstsql.Items.IndexOf(key) < 0 then
      lstsql.Items.Add(key);
  end;
  lstsql.Sorted := true;
end;

procedure TMVCMain.Button2Click(Sender: TObject);
begin
  if lstsql.ItemIndex > -1 then
  begin
    SQLCache.SQLList.Remove(lstsql.Items.Strings[lstsql.ItemIndex]);
    lstsql.DeleteSelected;
  end;
end;

procedure TMVCMain.Button3Click(Sender: TObject);
begin
  if lstsql.Count > 0 then
  begin
    SQLCache.SQLList.Clear;
    lstsql.Clear;
  end;
end;

procedure TMVCMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  if btnStart.Caption = '启动' then
    btnStart.Click;
  if Config.App.Trim <> '' then
    LURL := Format('http://localhost:%s%s', [edtport.Text, '/' + Config.App + '/'])
  else
    LURL := Format('http://localhost:%s', [edtport.Text]);
  OpenURL(LURL);
end;

procedure TMVCMain.stat1Click(Sender: TObject);
begin
  OpenDelphiWebMVC;
end;

procedure TMVCMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseServer;
end;

procedure TMVCMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not Config.open_debug then
  begin
    if Application.MessageBox('是否退出系统?', '提示', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = IDYES then
    begin
      CanClose := true;
    end
    else
      CanClose := false;
  end
  else
    CanClose := true;
end;

procedure TMVCMain.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
  TrayIcon1.SetDefaultIcon;
  if not Config.open_log then
    TrayIcon1.Visible := true;
  mmolog.Clear;
  edtport.ReadOnly := true;
  pgc1.ActivePageIndex := 0;
end;

procedure TMVCMain.FormShow(Sender: TObject);
begin
  mmoConfig.Lines.LoadFromFile(Config.config_path);
  mmoMIME.Lines.LoadFromFile(Config.mime_path);
  if Config.auto_start then
    btnStart.Click;
end;

procedure TMVCMain.LinkLabel1Click(Sender: TObject);
begin
  OpenDelphiWebMVC;
end;

procedure TMVCMain.OpenDelphiWebMVC;
begin
  OpenURL('https://gitee.com/pearroom/DelphiWebMVC');
end;

procedure TMVCMain.OpenURL(url: string);
begin
  ShellExecute(0, nil, PChar(url), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMVCMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE);
  Self.Show;
  Application.BringToFront;
end;

end.

