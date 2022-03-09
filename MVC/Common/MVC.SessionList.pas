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
  TSessionList = class(TThread)
    SessionLs_vlue: TDictionary<string, string>;
    SessionLs_timerout: TDictionary<string, string>;
  private
    procedure clearMap;
  protected
    procedure Execute; override;
  public
    function getValueByKey(sessionid: string): string;
    function getTimeroutByKey(sessionid: string): string;
    function setValueByKey(sessionid: string; value: string): boolean;
    function setTimeroutByKey(sessionid: string; timerout: string): boolean;
    function deleteSession(key: string): boolean;
    procedure delAllSessioin();
    function editTimerOut(sessionid: string; value: string): boolean;
    procedure getAllSession(var list: TStringList);
    constructor Create();
    destructor Destroy; override;
  end;

implementation



{ TSessionList2 }
procedure TSessionList.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(10);
    Inc(k);
    if k >= 1000 then
    begin
      k := 0;
      clearMap;

    end;

  end;
end;

procedure TSessionList.clearMap();
var
  key, s: string;
begin
  try
    for key in SessionLs_timerout.Keys do
    begin
      s := SessionLs_timerout.Items[key];
      if s.Trim <> '' then
      begin
        if Now() >= StrToDateTime(s) then
        begin
          if deleteSession(key) then
          begin
            //  log('清理Session-' + key);
            break;
          end;

        end;
      end;
    end;
  except
    Exit;
  end;
end;

constructor TSessionList.Create();
begin
  inherited Create(False);
  SessionLs_vlue := TDictionary<string, string>.Create;
  SessionLs_timerout := TDictionary<string, string>.Create;
end;

procedure TSessionList.delAllSessioin;
begin
  MonitorEnter(SessionLs_vlue);
  MonitorEnter(SessionLs_timerout);
  try
    SessionLs_vlue.Clear;
    SessionLs_timerout.Clear;
  finally
    MonitorExit(SessionLs_vlue);
    MonitorExit(SessionLs_timerout);
  end;
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

procedure TSessionList.getAllSession(var list: TStringList);
var
  key: string;
  i: Integer;
  tmp_list: TDictionary<string, string>;
begin
  MonitorEnter(SessionLs_timerout);
  tmp_list := TDictionary<string, string>.Create(SessionLs_timerout);
  MonitorExit(SessionLs_timerout);
  i := 0;
  try
    for key in tmp_list.Keys do
    begin
      list.Add('[' + i.ToString + '] KEY:' + key + ' TimeOut:' + tmp_list[key]);
      inc(i);
    end;
  finally
    tmp_list.Clear;
    tmp_list.Free;
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

