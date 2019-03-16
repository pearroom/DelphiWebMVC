{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit SessionList;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Generics.Collections;

type
  TSessionList = class
    SessionLs_vlue: TDictionary<string, string>;
    SessionLs_timerout: TDictionary<string, string>;
  public
    function getValueByKey(sessionid: string): string;
    function getTimeroutByKey(sessionid: string): string;
    function setValueByKey(sessionid: string; value: string): boolean;
    function setTimeroutByKey(sessionid: string; timerout: string): boolean;
    function deleteSession(key:string): boolean;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  Command;

{ TSessionList2 }

constructor TSessionList.Create();
begin

  SessionLs_vlue := TDictionary<string, string>.Create;
  SessionLs_timerout := TDictionary<string, string>.Create;
end;

function TSessionList.deleteSession(key:string): boolean;
begin
  Result := false;
  if SessionLs_timerout.Count > 0 then
  begin
    try
      SessionLs_timerout.Remove(key);
      if SessionLs_vlue.Count > 0 then
      begin
        SessionLs_vlue.Remove(key);
      end;
      Result := true;
    except
      Result := false;
    end;
  end;
end;

destructor TSessionList.Destroy;
begin
  SessionLs_vlue.Clear;
  SessionLs_timerout.Clear;
  SessionLs_vlue.Free;
  SessionLs_timerout.Free;
  inherited;
end;

function TSessionList.getTimeroutByKey(sessionid: string): string;
var
  s: string;
begin

  SessionLs_timerout.TryGetValue(sessionid, s);

  Result := s;

end;

function TSessionList.getValueByKey(sessionid: string): string;
var
  s: string;
begin

  SessionLs_vlue.TryGetValue(sessionid, s);

  Result := s;

end;

function TSessionList.setTimeroutByKey(sessionid, timerout: string): boolean;
begin

  SessionLs_timerout.AddOrSetValue(sessionid, timerout);
end;

function TSessionList.setValueByKey(sessionid, value: string): boolean;
begin
  SessionLs_vlue.AddOrSetValue(sessionid, value);

end;

end.

