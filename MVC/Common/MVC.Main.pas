unit MVC.Main;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, MVC.PageCache;

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
    img1: TImage;
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
  private
    function readlog(var str: TMemo; var msg: string): boolean;
    { Private declarations }
  public

    { Public declarations }
  end;

var
  MVCMain: TMVCMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows, Winapi.ShellApi, MVC.command, MVC.LogUnit, MVC.Config;

procedure TMVCMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then
  begin
    Application.Minimize;
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TMVCMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TMVCMain.readlog(var str: TMemo; var msg: string): boolean;
var
  logfile: string;
begin
  Result := false;
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
      msg := logfile + '未找到日志文件';
      Result := false;
    end;
  end
  else
  begin
    msg := '日志功能未开启';
    Result := false;
  end;
end;

procedure TMVCMain.btndelallClick(Sender: TObject);
begin
  if lstpage.Count > 0 then
  begin
    _PageCache.PageList.Clear;
    lstpage.Clear;
  end;
end;

procedure TMVCMain.btndelClick(Sender: TObject);
begin
  if lstpage.ItemIndex > -1 then
  begin
    _PageCache.PageList.Remove(lstpage.Items.Strings[lstpage.ItemIndex]);
    lstpage.DeleteSelected;
  end;
end;

procedure TMVCMain.btnloggetClick(Sender: TObject);
var
  msg: string;
begin
  lbllog.Caption := 'Loading...';
  TThread.CreateAnonymousThread(
    procedure
    begin
      if not readlog(mmolog, msg) then
      begin
        mmolog.Lines.Add(msg);
        lbllog.Caption := 'load Error';
      end
      else
        lbllog.Caption := 'Load Over';
    end).Start;
end;

procedure TMVCMain.btnRefreshConfigClick(Sender: TObject);
begin
  mmoConfig.Lines.LoadFromFile(Config.config, TEncoding.UTF8);
end;

procedure TMVCMain.btnRefreshMimeClick(Sender: TObject);
begin
  mmoMIME.Lines.LoadFromFile(Config.mime);
end;

procedure TMVCMain.btnRemoveSessionAllClick(Sender: TObject);
begin
  if lstSession.Count > 0 then
  begin
    _SessionListMap.delAllSessioin;
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
    _SessionListMap.deleteSession(key);
    lstSession.DeleteSelected;
  end;
end;

procedure TMVCMain.btnSaveConfigClick(Sender: TObject);
begin
  mmoConfig.Lines.SaveToFile(Config.config, TEncoding.UTF8);
  _ConfigJSON := OpenConfigFile();
  if _ConfigJSON <> nil then
  begin
    if (_ConfigJSON['AppTitle'] <> nil) and (_ConfigJSON['AppTitle'].AsString <> '') then
    begin
      Application.Title := _ConfigJSON['AppTitle'].AsString;
      Caption := Application.Title;
    end;
  end;
end;

procedure TMVCMain.btnSaveMimeClick(Sender: TObject);
begin
  mmoMIME.Lines.SaveToFile(Config.mime, TEncoding.UTF8);
end;

procedure TMVCMain.btnseachClick(Sender: TObject);
var
  key: string;
begin
  for key in _PageCache.PageList.Keys do
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
  _SessionListMap.getAllSession(sList);
  lstSession.Items := sList;
  sList.Free;
end;

procedure TMVCMain.btnStartClick(Sender: TObject);
begin
  if btnStart.Caption = 'Start' then
  begin
    edtport.Text := StartServer;
    if edtport.Text = '0000' then
    begin
      mmolog.Lines.Add('config.json Error');
      ButtonOpenBrowser.Enabled := false;
    end
    else
    begin
      btnStart.Caption := 'Stop';

    end;
  end
  else
  begin
    CloseServer;
    edtport.Text := '0';
    btnStart.Caption := 'Start';
  end;

end;

procedure TMVCMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  if Config.__APP__.Trim <> '' then
    LURL := Format('http://localhost:%s%s', [edtport.Text, '/' + Config.__APP__ + '/'])
  else
    LURL := Format('http://localhost:%s', [edtport.Text]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMVCMain.stat1Click(Sender: TObject);
begin
  ShellExecute(0, nil, PChar('https://my.oschina.net/delphimvc'), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMVCMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if btnStart.Caption = 'Stop' then
    CloseServer;
end;

procedure TMVCMain.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
  TrayIcon1.SetDefaultIcon;
  TrayIcon1.Visible := true;
  mmolog.Clear;
  edtport.ReadOnly := true;
  pgc1.ActivePageIndex := 0;

end;

procedure TMVCMain.FormShow(Sender: TObject);
begin
  mmoConfig.Lines.LoadFromFile(Config.config);
  mmoMIME.Lines.LoadFromFile(Config.mime);
end;

procedure TMVCMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE);
  Self.Show;
  Application.BringToFront;
end;

end.

