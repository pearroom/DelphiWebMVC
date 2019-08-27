unit MVC.Main;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, MVC.PageCache;

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
    mmolog: TMemo;
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
  Winapi.Windows, Winapi.ShellApi, MVC.command, MVC.LogUnit, uConfig;

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
  if open_log then
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
  _PageCache.PageList.Clear;
  lstpage.Clear;
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

procedure TMVCMain.btnseachClick(Sender: TObject);
var
  i: Integer;
  key: string;
begin
  for key in _PageCache.PageList.Keys do
  begin
    if lstpage.Items.IndexOf(key) < 0 then
      lstpage.Items.Add(key);
  end;
  lstpage.Sorted := true;
end;

procedure TMVCMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  if __APP__.Trim <> '' then
    LURL := Format('http://localhost:%s%s', [edtport.Text, '/' + __APP__ + '/'])
  else
    LURL := Format('http://localhost:%s', [edtport.Text]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMVCMain.stat1Click(Sender: TObject);
begin
  ShellExecute(0, nil, PChar('http://www.delphiwebmvc.com'), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMVCMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
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

  edtport.Text := StartServer;
  if edtport.Text = '0000' then
  begin
    mmolog.Lines.Add('服务启动失败,请检查配置文件');
    ButtonOpenBrowser.Enabled := false;
  end;
end;

procedure TMVCMain.FormShow(Sender: TObject);
begin
  //btnlogget.Click;
end;

procedure TMVCMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE);
  Self.Show;
  Application.BringToFront;
end;

end.

