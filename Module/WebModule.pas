unit WebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, Web.ReqMulti;

type
  TWM = class(TWebModule)
    WebFile: TWebFileDispatcher;
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  end;

var
  WebModuleClass: TComponentClass = TWM;

implementation

uses
  command, superobject;

{$R *.dfm}

procedure TWM.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  try
    OpenRoule(Self, RouleMap, Handled);
  except
    on e: Exception do
    begin
      log(e.ToString);
      Response.Content := e.ToString;
      Response.SendResponse;
    end;

  end;

end;

procedure TWM.WebModuleCreate(Sender: TObject);
var
  json: ISuperObject;
  ja: TSuperArray;
  I: Integer;
begin
  WebFile.WebFileExtensions.Clear;
  json := OpenMIMEFile;
  if json <> nil then
  begin
    ja := json.AsArray;
    for I := 0 to ja.Length - 1 do
    begin
      with WebFile.WebFileExtensions.Add do
      begin
        Extensions := ja[I]['Extensions'].AsString;
        MimeType := ja[I]['MimeType'].AsString;
      end;
    end;
  end;
end;

end.

