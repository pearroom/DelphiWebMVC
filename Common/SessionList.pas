unit SessionList;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, FireDAC.Comp.Client,
  superobject, uConfig, System.Contnrs, Generics.Collections;

type
  TSessionObj = class
  private
    FTimerOut: TDateTime;
    FSessionID: string;
    procedure SetSessionID(const Value: string);
    procedure SetTimerOut(const Value: TDateTime);
  published
    property SessionID: string read FSessionID write SetSessionID;
    property TimerOut: TDateTime read FTimerOut write SetTimerOut;
  public
    JO: TStringList;
    constructor Create();
    destructor Destroy; override;
  end;

type
  TSessionList = class
  private
    JOList: TObjectList<TSessionObj>;
  public
    constructor Create();
    destructor Destroy; override;
    function get(key: string): TSessionObj;
    procedure put(key: string; value: TSessionObj);
    function item(i: Integer): TSessionObj;
    procedure remove(i: Integer);
    function count(): integer;
  end;

implementation

{ TSessionList }

function TSessionList.count: integer;
begin
  Result := JOList.Count;
end;

constructor TSessionList.Create();
begin
  inherited;
  JOList := TObjectList<TSessionObj>.Create();
end;

destructor TSessionList.Destroy;
begin
  JOList.Clear;
  JOList.Free;
  inherited;
end;

function TSessionList.get(key: string): TSessionObj;
var
  i: integer;
  sobj: TSessionObj;
begin
  Result := nil;
  for i := 0 to JOList.Count - 1 do
  begin
    sobj := JOList.Items[i];
    if sobj.SessionID = key then
    begin
      Result := sobj;
      Break;
    end;
  end;

end;

function TSessionList.item(i: Integer): TSessionObj;
begin
  Result := JOList.Items[i];
end;

procedure TSessionList.put(key: string; value: TSessionObj);
var
  i: integer;
  isok: Boolean;
begin
  isok := false;
  for i := 0 to JOList.Count - 1 do
  begin
    if JOList.Items[i].SessionID = key then
    begin
   //   JOList.Items[i]:=value;
      isok := true;
      Break;
    end;
  end;
  if not isok then
  begin
    JOList.Add(value);
  end;

end;

procedure TSessionList.remove(i: Integer);
begin
  JOList.Delete(i);
 // JOList.Remove(JOList.Items[i]);
end;

{ TSessionObj }

constructor TSessionObj.Create();
begin
  inherited;
  jo := TStringList.Create;
end;

destructor TSessionObj.Destroy;
begin
  jo.Clear;
  JO.Free;
  inherited;
end;

procedure TSessionObj.SetSessionID(const Value: string);
begin
  FSessionID := Value;
end;

procedure TSessionObj.SetTimerOut(const Value: TDateTime);
begin
  FTimerOut := Value;
end;

end.

