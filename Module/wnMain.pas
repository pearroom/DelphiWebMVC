unit wnMain;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, superobject,
  Vcl.ComCtrls, Vcl.Imaging.pngimage;

type
  TMain = class(TForm)
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
    pnl1: TPanel;
    img1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure stat1Click(Sender: TObject);
    procedure btnloggetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private


    { Private declarations }
  public

    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows, Winapi.ShellApi, command, LogUnit, uConfig;

procedure TMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then
  begin
    Application.Minimize;
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TMain.btnCloseClick(Sender: TObject);

begin
  Close;
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

procedure TMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  if __APP__.Trim <> '' then
    LURL := Format('http://localhost:%s%s', [edtport.Text, '/' + __APP__ + '/'])
  else
    LURL := Format('http://localhost:%s', [edtport.Text]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMain.stat1Click(Sender: TObject);
begin
  ShellExecute(0, nil, PChar('http://www.delphiwebmvc.com'), nil, nil, SW_SHOWNOACTIVATE);
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

  edtport.Text := StartServer;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  //btnlogget.Click;
end;

procedure TMain.TrayIcon1Click(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNOACTIVATE);
  Self.Show;
  Application.BringToFront;
end;

end.

