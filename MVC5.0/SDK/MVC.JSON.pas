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
    function O: TJSONObject;
    function ParseJSON(value: string): TJSONObject;
    function toJSON: string;
    procedure SetS(key: string; value: string); overload;
    procedure SetI(key: string; value: Integer); overload;
    procedure SetD(key: string; value: Double); overload;
    procedure SetB(key: string; value: Boolean); overload;
    function GetI(key: string): Integer;
    function GetD(key: string): Double;
    function GetS(key: string): string;
    function GetB(key: string): Boolean;
    procedure Remove(key: string);
  end;

  TJObject = class(TInterfacedObject, IJObject)
  private
    jsonObj: TJSONObject;
  public
    function O: TJSONObject;
    function ParseJSON(value: string): TJSONObject;
    function toJSON: string;
    procedure SetS(key: string; value: string); overload;
    procedure SetI(key: string; value: Integer); overload;
    procedure SetD(key: string; value: Double); overload;
    procedure SetB(key: string; value: Boolean); overload;
    function GetI(key: string): Integer;
    function GetD(key: string): Double;
    function GetS(key: string): string;
    function GetB(key: string): Boolean;
    procedure Remove(key: string);
    constructor Create(json: string = '');
    destructor Destroy; override;
  end;

  IJArray = interface
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

function TJObject.GetD(key: string): Double;
begin
  Result := 0;
  if jsonObj.Get(key) <> nil then
    Result := jsonObj.GetValue(key).Value.ToDouble;
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

procedure TJObject.SetD(key: string; value: Double);
begin
  jsonObj.RemovePair(key).Free;
  jsonObj.AddPair(key, TJSONNumber.Create(value));
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

