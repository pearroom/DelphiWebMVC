{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.RouteItem;

interface

uses
  System.Rtti;

type
  TRouteItem = class
  private
    FPath: string;
    FName: string;
    FAction: TClass;
    FInterceptor: Boolean;
    procedure SetAction(const Value: TClass);
    procedure SetName(const Value: string);
    procedure SetPath(const Value: string);
    procedure SetInterceptor(const Value: Boolean);
  public
    ActoinClass: TRttiType;
    SetParams, FreeDb, ShowHTML,Interceptor: TRttiMethod;
    Response, Request, ActionPath, ActionRoute: TRttiProperty;
    property isInterceptor: Boolean read FInterceptor write SetInterceptor;
    property Name: string read FName write SetName;
    property Action: TClass read FAction write SetAction;
    property path: string read FPath write SetPath;
    function ActionMethod(methodname: string): TRttiMethod;
  end;

implementation

{ TRouteItem }

function TRouteItem.ActionMethod(methodname: string): TRttiMethod;
begin
  result := ActoinClass.GetMethod(methodname);
end;

procedure TRouteItem.SetAction(const Value: TClass);
begin
  FAction := Value;
end;

procedure TRouteItem.SetInterceptor(const Value: Boolean);
begin
  FInterceptor := Value;
end;

procedure TRouteItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TRouteItem.SetPath(const Value: string);
begin
  FPath := Value;
end;

end.

