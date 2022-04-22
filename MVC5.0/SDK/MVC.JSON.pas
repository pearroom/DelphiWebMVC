unit MVC.JSON;

interface

uses
  System.JSON, System.SysUtils, System.Classes, System.Generics.Collections,
  Web.HTTPApp, System.Net.URLClient, Web.ReqMulti, MVC.Tool;

type
//  TJSONObject = TJSONObject;
//
//  TJSONArray = TJSONArray;

  IJObject = interface
    ['{FEC2FAB3-E39D-461B-8A1C-ECE2B83436E2}']
    function O: TJSONObject;
    function ParseJSON(value: string): TJSONObject;
    function toJSON: string;
    procedure Remove(key: string);
    procedure SetF(key: string; const Value: double);
    procedure SetS(key: string; value: string); overload;
    procedure SetI(key: string; value: Integer); overload;
    procedure SetD(key: string; value: TDateTime); overload;
    procedure SetB(key: string; value: Boolean); overload;
    function GetI(key: string): Integer;
    function GetF(key: string): Double;
    function GetD(key: string): TDateTime;
    function GetS(key: string): string;
    function GetB(key: string): Boolean;
    property S[key: string]: string read GetS write SetS;
    property I[key: string]: integer read GetI write SetI;
    property B[key: string]: boolean read GetB write SetB;
    property D[key: string]: TDateTime read GetD write SetD;
    property F[key: string]: double read GetF write SetF;
  end;

  TJObject = class(TInterfacedObject, IJObject)
  private
    jsonObj: TJSONObject;

  public
    function O: TJSONObject;
    function ParseJSON(value: string): TJSONObject;
    function toJSON: string;

    procedure SetF(key: string; const Value: double);
    procedure SetS(key: string; value: string); overload;
    procedure SetI(key: string; value: Integer); overload;
    procedure SetD(key: string; value: TDateTime); overload;
    procedure SetB(key: string; value: Boolean); overload;

    function GetI(key: string): Integer;
    function GetF(key: string): Double;
    function GetD(key: string): TDateTime;
    function GetS(key: string): string;
    function GetB(key: string): Boolean;

    property S[key: string]: string read GetS write SetS;
    property I[key: string]: integer read GetI write SetI;
    property B[key: string]: boolean read GetB write SetB;
    property D[key: string]: TDateTime read GetD write SetD;
    property F[key: string]: double read GetF write SetF;

    procedure Remove(key: string);
    constructor Create(json: string = '');
    destructor Destroy; override;
  end;

  IJArray = interface
    ['{5131E207-0B1E-4AB8-B0D8-B9B8453342B7}']
    function A: TJSONArray;
    function ParseJSON(value: string): TJSONArray;
    function toJSON: string;
  end;

  TJArray = class(TInterfacedObject, IJArray)
  private
    jsonArr: TJSONArray;
  public
    function A: TJSONArray;
    function ParseJSON(value: string): TJSONArray;
    function toJSON: string;
    constructor Create(json: string = '');
    destructor Destroy; override;
  end;

function IIJObject(json: string = ''): IJObject;

function IIJArray(json: string = ''): IJArray;

implementation

{ TJSON }
function IIJObject(json: string): IJObject;
begin
  Result := TJObject.Create(json) as IJObject;
end;

function IIJArray(json: string): IJArray;
begin
  Result := TJArray.Create(json) as IJArray;
end;

constructor TJObject.Create(json: string);
begin
  if json.Trim = '' then
    jsonobj := TJSONObject.Create
  else
    jsonObj := TJSONObject.ParseJSONValue(json) as TJSONObject;
end;

destructor TJObject.Destroy;
begin
  jsonobj.Free;
  inherited;
end;

function TJObject.GetB(key: string): Boolean;
begin
  Result := False;
  if jsonObj.Get(key) <> nil then
    Result := jsonObj.GetValue(key).Value.ToBoolean;
end;

function TJObject.GetD(key: string): TDateTime;
begin
  Result := 0;
  if jsonObj.Get(key) <> nil then
    Result := StrToDateTime(jsonObj.GetValue(key).Value);
end;

function TJObject.GetF(key: string): double;
begin
  Result := 0;
  if jsonObj.Get(key) <> nil then
    Result := jsonObj.GetValue(key).Value.ToDouble();
end;

function TJObject.GetI(key: string): Integer;
begin
  Result := 0;
  if jsonObj.Get(key) <> nil then
    Result := jsonObj.GetValue(key).Value.ToInteger;
end;

function TJObject.GetS(key: string): string;
begin
  Result := '';
  if jsonObj.Get(key) <> nil then
  begin
    Result := jsonObj.GetValue(key).Value;
    if Result = '' then
      Result := jsonObj.GetValue(key).ToJSON;
  end;
end;

function TJObject.O: TJSONObject;
begin
  Result := jsonobj;
end;

function TJObject.ParseJSON(value: string): TJSONObject;
begin
  jsonObj.Free;
  jsonObj := TJSONObject.ParseJSONValue(value) as TJSONObject;
  Result := jsonObj;
end;

procedure TJObject.Remove(key: string);
begin
  jsonObj.RemovePair(key).Free;
end;

procedure TJObject.SetD(key: string; value: TDateTime);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, TJSONString.Create(DateTimeToStr(value)));
end;

procedure TJObject.SetF(key: string; const Value: double);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, TJSONNumber.Create(Value));
end;

procedure TJObject.SetS(key, value: string);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, value);
end;

procedure TJObject.SetI(key: string; value: Integer);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, TJSONNumber.Create(value));
end;

procedure TJObject.SetB(key: string; value: Boolean);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, TJSONBool.Create(value));
end;

function TJObject.toJSON: string;
begin
  result := jsonObj.ToJSON;
end;

{ TJsonJA }

constructor TJArray.Create(json: string);
begin
  if json.Trim = '' then
    jsonarr := TJSONArray.Create
  else
    jsonArr := TJSONObject.ParseJSONValue(json) as TJSONArray;
end;

destructor TJArray.Destroy;
begin
  jsonarr.Free;
  inherited;
end;

function TJArray.A: TJSONArray;
begin
  Result := jsonArr;
end;

function TJArray.ParseJSON(value: string): TJSONArray;
begin
  jsonarr.Free;
  jsonArr := TJSONObject.ParseJSONValue(value) as TJSONArray;
  Result := jsonArr;
end;

function TJArray.toJSON: string;
begin
  result := jsonArr.ToJSON;
end;

end.

