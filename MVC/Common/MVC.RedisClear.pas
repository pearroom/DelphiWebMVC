{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.RedisClear;

interface

uses
  System.SysUtils, System.Classes;

type
  TRedisClear = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

uses
  MVC.Command;

{ TRedisClear }

procedure TRedisClear.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(100);
    Inc(k);
    if k >= 100 then
    begin
      k := 0;
      _RedisList.RunClear;

    end;

  end;
end;

end.

