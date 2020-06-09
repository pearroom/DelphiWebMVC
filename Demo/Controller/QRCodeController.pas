unit QRCodeController;

interface

uses
  System.SysUtils, System.Classes, MVC.BaseController, Vcl.Graphics;

type
  TQRCodeController = class(TBaseController)
  public
    procedure index;
    procedure makecode;
  end;

implementation

uses
  uGlobal;

{ TPayController }

procedure TQRCodeController.index;
begin
  with View do
  begin
    ShowHTML('index');
  end;
end;

procedure TQRCodeController.makecode;
var
  image64: string;
  filename: string;
  url: string;
begin

  with view do
  begin
    filename := 'qrcode/' + GetGUID + '.bmp';
    url := Input('url');
    if url.Trim = '' then
    begin
      Fail();
    end
    else
    begin
      Global.QRCode_Create(url, AppPath + filename, 0);
      Success(0, '/' + filename);
    end;
  end;
end;

initialization
  SetRoute('qrcode', TQRCodeController, 'qrcode');

end.

