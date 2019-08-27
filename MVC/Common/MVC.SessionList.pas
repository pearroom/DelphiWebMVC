{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.SessionList;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, MVC.LogUnit;

type
  TSessionList = class
    SessionLs_vlue: TDictionary<string, string>;
    SessionLs_timerout: TDictionary<string, string>;
  public
    function getValueByKey(sessionid: string): string;
    function getTimeroutByKey(sessionid: string): string;
    function setValueByKey(sessionid: string; value: string): boolean;
    function setTimeroutByKey(sessionid: string; timerout: string): boolean;
    function deleteSession(key: string): boolean;
    function editTimerOut(sessionid: string; value: string): boolean;
    constructor Create();
    destructor Destroy; override;
  end;

implementation



{ TSessionList2 }

constructor TSessionList.Create();
begin

  SessionLs_vlue := TDictionary<string, string>.Create;
  SessionLs_timerout := TDictionary<string, string>.Create;
end;

function TSessionList.deleteSession(key: string): boolean;
begin
  MonitorEnter(SessionLs_vlue);
  MonitorEnter(SessionLs_timerout);
  try
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
  finally
    MonitorExit(SessionLs_vlue);
    MonitorExit(SessionLs_timerout);
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

function TSessionList.editTimerOut(sessionid, value: string): boolean;
begin
  if SessionLs_timerout.ContainsKey(sessionid) then
  begin
    MonitorEnter(SessionLs_timerout);
    try

      SessionLs_timerout.AddOrSetValue(sessionid, value);
    finally
      MonitorExit(SessionLs_timerout);
    end;
  end;
end;

function TSessionList.getTimeroutByKey(sessionid: string): string;
var
  s: string;
begin
  MonitorEnter(SessionLs_timerout);
  try
    try
      SessionLs_timerout.TryGetValue(sessionid, s);
    except
      log('getTimeroutByKey error');
    end;
  finally
    MonitorExit(SessionLs_timerout);
  end;

  Result := s;
end;

function TSessionList.getValueByKey(sessionid: string): string;
var
  s: string;
begin

  MonitorEnter(SessionLs_vlue);
  try
    try
      SessionLs_vlue.TryGetValue(sessionid, s);
    except
      log('getValueByKey error');
    end;
  finally
    MonitorExit(SessionLs_vlue);
  end;

  Result := s;
end;

function TSessionList.setTimeroutByKey(sessionid, timerout: string): boolean;
begin
  MonitorEnter(SessionLs_timerout);
  try
    try
      SessionLs_timerout.AddOrSetValue(sessionid, timerout)
    except
      log('session error1');
    end;
  finally
    MonitorExit(SessionLs_timerout);
  end;
  Result := true;
end;

function TSessionList.setValueByKey(sessionid, value: string): boolean;
begin
  MonitorEnter(SessionLs_vlue);
  try
    try
      SessionLs_vlue.AddOrSetValue(sessionid, value);
    except
      log('session error2');
    end;
  finally
    MonitorExit(SessionLs_vlue);
  end;
  Result := true;
end;

end.

