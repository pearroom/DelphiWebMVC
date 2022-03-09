{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.ThSessionClear;

interface

uses
  System.Classes, System.SysUtils, MVC.Command;

type
  TThSessionClear = class(TThread)
  private
    procedure clearMap;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    isstop: boolean;
  end;

implementation



{ TThSession }
procedure TThSessionClear.clearMap();
var
  key, s: string;
begin
  try
    if _SessionListMap <> nil then
    begin
      for key in _SessionListMap.SessionLs_timerout.Keys do
      begin
        s := _SessionListMap.SessionLs_timerout.Items[key];
        if s.Trim <> '' then
        begin
          if Now() >= StrToDateTime(s) then
          begin
            if _SessionListMap.deleteSession(key) then
            begin
            //  log('清理Session-' + key);
              break;
            end;

          end;
        end;
      end;

    end;
  except
    Exit;
  end;
end;

procedure TThSessionClear.Execute;
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

end.

