{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.Config;

interface

uses
  MVC.LogUnit, MVC.JSON, System.JSON, System.SysUtils, System.Classes, HTTPApp,
  MVC.DES, System.Generics.Collections, MVC.Tool;

type
  TCorss_Origin = record
    Allow_Origin: string;
    Allow_Headers: string;
    Allow_Method: string;
    Allow_Credentials: Boolean;
  end;

  TRedisParams = record
    Host: string;
    Port: integer;
    PassWrod: string;
    InitSize: integer;
    TimeOut: integer;
    ReadTimeOut: integer;

  end;

  TConfig = class
  private
    directory_permission: TDictionary<string, Boolean>;
    over: Boolean;
    FApp: string;
    FWebRoot: string;
    FPort: string;
    FThreadCount: Integer;
    Fdocument_charset: string;
    Fopen_log: Boolean;
    Fsession_start: Boolean;
    Fsession_timer: Integer;
    Fopen_cache: boolean;
    Fopen_debug: Boolean;
    Fcache_max_age: string;
    Fmime_path: string;
    Fconfig_path: string;
    Fpassword_key: string;
    Ftemplate: string;
    Ftemplate_type: string;
    FError404: string;
    FError500: string;
    FCompress: string;
    FCorss_Origin: TCorss_Origin;
    FHTTPQueueLength: Integer;
    Fauto_start: boolean;
    Fsessoin_name: string;
    FAppTitle: string;
    Froute_suffix: string;
    FJsonToLower: Boolean;
    FDBConfig: string;
    Fshow_sql: Boolean;
    FWinServiceConfig: string;
    FBasePath: string;
    FleftFmt: string;
    FrightFmt: string;
    Fredis: TRedisParams;
    procedure SetApp(const Value: string);
    procedure SetPort(const Value: string);
    procedure SetWebRoot(const Value: string);
    procedure SetThreadCount(const Value: Integer);
    procedure Setdocument_charset(const Value: string);
    procedure Setopen_log(const Value: Boolean);
    procedure Setsession_start(const Value: Boolean);
    procedure Setsession_timer(const Value: Integer);
    procedure Setopen_cache(const Value: boolean);
    procedure Setopen_debug(const Value: Boolean);
    procedure Setcache_max_age(const Value: string);
    procedure Setconfig_path(const Value: string);
    procedure Setmime_path(const Value: string);
    procedure Setpassword_key(const Value: string);
    procedure Settemplate(const Value: string);
    procedure Settemplate_type(const Value: string);
    procedure SetError404(const Value: string);
    procedure SetError500(const Value: string);
    procedure SetCompress(const Value: string);
    procedure SetCorss_Origin(const Value: TCorss_Origin);
    procedure SetHTTPQueueLength(const Value: Integer);
    procedure Setauto_start(const Value: boolean);
    procedure Setsessoin_name(const Value: string);
    procedure SetAppTitle(const Value: string);
    procedure Setroute_suffix(const Value: string);
    procedure SetJsonToLower(const Value: Boolean);
    procedure SetDBConfig(const Value: string);
    procedure Setshow_sql(const Value: Boolean);
    procedure SetWinServiceConfig(const Value: string);
    procedure SetBasePath(const Value: string);
    procedure SetleftFmt(const Value: string);
    procedure SetrightFmt(const Value: string);
    procedure Setredis(const Value: TRedisParams);

  public
    MIME: TDictionary<string, string>;
    property BasePath: string read FBasePath write SetBasePath;
    property AppTitle: string read FAppTitle write SetAppTitle;
    property App: string read FApp write SetApp;
    property Port: string read FPort write SetPort;
    property WebRoot: string read FWebRoot write SetWebRoot;
    property ThreadCount: Integer read FThreadCount write SetThreadCount;
    property document_charset: string read Fdocument_charset write Setdocument_charset;
    property open_log: Boolean read Fopen_log write Setopen_log;
    property session_start: Boolean read Fsession_start write Setsession_start;
    property session_timer: Integer read Fsession_timer write Setsession_timer;
    property open_cache: boolean read Fopen_cache write Setopen_cache;
    property open_debug: Boolean read Fopen_debug write Setopen_debug;
    property cache_max_age: string read Fcache_max_age write Setcache_max_age;
    property config_path: string read Fconfig_path write Setconfig_path;
    property mime_path: string read Fmime_path write Setmime_path;
    property password_key: string read Fpassword_key write Setpassword_key; //对配置文件进行加密解密秘钥
    property template: string read Ftemplate write Settemplate;
    property template_type: string read Ftemplate_type write Settemplate_type;
    property Error404: string read FError404 write SetError404;
    property Error500: string read FError500 write SetError500;
    property Corss_Origin: TCorss_Origin read FCorss_Origin write SetCorss_Origin; //支持跨域访问
    property Compress: string read FCompress write SetCompress;
    property HTTPQueueLength: Integer read FHTTPQueueLength write SetHTTPQueueLength;
    property auto_start: boolean read Fauto_start write Setauto_start;
    property sessoin_name: string read Fsessoin_name write Setsessoin_name;
    property suffix: string read Froute_suffix write Setroute_suffix; //伪静态后缀
    property JsonToLower: Boolean read FJsonToLower write SetJsonToLower;
    property DBConfig: string read FDBConfig write SetDBConfig; //存储数据库配置数据
    property show_sql: Boolean read Fshow_sql write Setshow_sql;
    property WinServiceConfig: string read FWinServiceConfig write SetWinServiceConfig;
    property leftFmt: string read FleftFmt write SetleftFmt; //左边分割字符
    property rightFmt: string read FrightFmt write SetrightFmt; //右边分割字符
    property redis: TRedisParams read Fredis write Setredis; //redis 参数
    //
    function check_directory_permission(path: string): Boolean; //检查目录的访问权限
    function read_config(): IJObject; // 读取 config.json 配置文件
    function read_mime(): IJArray; //读取mime.json 配置文件
    procedure setParams(json: IJObject); //初始化config配置参数
    //
    function isOver: Boolean; //配置文件是否成功配置完毕
    function initParams(): Boolean; //初始化配置参数
    procedure setPassword(password: string); //设置解密秘钥
    function read_title: string;
    constructor Create();
    destructor Destroy; override;
  end;

var
  Config: TConfig;

procedure Lock(aObject: TObject);

procedure UnLock(aObject: TObject);

function GetGUID: string;

implementation

{ TConfig }
function GetGUID: string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  result := sGUID;
end;

procedure Lock(aObject: TObject);
begin
  MonitorEnter(aObject);
end;

procedure UnLock(aObject: TObject);
begin
  MonitorExit(aObject);
end;

function TConfig.check_directory_permission(path: string): Boolean;
var
  key: string;
  ret: Boolean;
begin
  ret := true;
  for key in directory_permission.Keys do
  begin
    if copy(path, 0, length(key)) = key then
    begin
      directory_permission.TryGetValue(key, ret);
      break;
    end;
  end;
  Result := ret;
end;

constructor TConfig.Create();
begin
  MIME := TDictionary<string, string>.Create;
  directory_permission := TDictionary<string, Boolean>.Create;
end;

destructor TConfig.Destroy;
begin
  directory_permission.Free;
  MIME.Free;

  inherited;
end;

function TConfig.initParams(): Boolean;
begin
  show_sql := false;
  App := '';
  Port := '8001';
  WebRoot := 'WebRoot';
  ThreadCount := 10;
  document_charset := 'utf-8';
  open_log := true;
  session_start := true;
  open_cache := true;
  open_debug := True;
  cache_max_age := '315360000';
  template := 'view';
  template_type := '.html';
  Error404 := '404';
  Error500 := '500';
  leftFmt := '#{';
  rightFmt := '}';
  config_path := Config.BasePath + 'Resources\config.json';
  mime_path := Config.BasePath + 'Resources\mime.json';
  HTTPQueueLength := 1000;
  session_timer := 30;
  suffix := '.html';
  sessoin_name := '__guid_session';
  JsonToLower := false;
  over := false;
  if (Config.read_config <> nil) and (Config.read_mime <> nil) then
    over := true;
  Result := over;
end;

function TConfig.isOver: Boolean;
begin
  Result := over; //检查配置文件是否成功读取
end;

function TConfig.read_config(): IJObject;
var
  f: TStringList;
  txt, filepath: string;
  key: string;
  jo: IJObject;
begin

  filepath := config_path;
  filepath := IITool.PathFmt(filepath);
  if not FileExists(filepath) then
  begin
    WriteLog(config_path + '配置文件不存在');
    Result := nil;
    exit;
  end;
  key := password_key;
  f := TStringList.Create;
  f.LoadFromFile(filepath, TEncoding.UTF8);
  txt := f.Text.Trim;
  try
    if Trim(key) = '' then
    begin
      txt := f.Text;
    end
    else
    begin
      txt := DeCryptStr(txt, key);
    end;
    try
      jo := IIJObject(txt);
      setParams(jo); //参数初始化
    except
      on e: Exception do
      begin
        WriteLog(e.Message);
        jo := nil;
      end;
    end;
  finally
    f.Free;
  end;
  if jo = nil then
  begin
    WriteLog(config_path + '配置文件加载失败');
    Result := nil;
  end
  else
  begin
    over := true;
    Result := jo;
  end;
end;

function TConfig.read_mime: IJArray;
var
  f: TStringList;
  txt: string;
  jarr: IJArray;
  i: Integer;
  jo1: TJSONObject;
  ekey, mValue: string;
  filepath: string;
begin
  filepath := mime_path;
  filepath := IITool.PathFmt(filepath);
  if not FileExists(filepath) then
  begin
    WriteLog(config_path + '配置文件不存在');
    Result := nil;
    exit;
  end;
  f := TStringList.Create;
  try
    mime.Clear;
    f.LoadFromFile(filepath);
    try
      txt := f.Text.Trim;
      jarr := IIJArray(txt);

      for i := 0 to jarr.A.Count - 1 do
      begin
        jo1 := jarr.A.Items[i] as TJSONObject;
        ekey := jo1.GetValue('Extensions').Value;
        mValue := jo1.GetValue('MimeType').Value;
        MIME.Add(ekey, mValue);
      end;
    except
      jarr := nil;
      over := false;
    end;
  finally
    f.Free;
  end;
  if jarr = nil then
  begin
    WriteLog(config_path + '配置文件加载失败');
    over := true;
  end;
  Result := jarr;
end;

function TConfig.read_title: string;
begin

end;

procedure TConfig.SetApp(const Value: string);
begin
  FApp := Value;
end;

procedure TConfig.SetAppTitle(const Value: string);
begin
  FAppTitle := Value;
end;

procedure TConfig.Setauto_start(const Value: boolean);
begin
  Fauto_start := Value;
end;

procedure TConfig.SetBasePath(const Value: string);
begin
  FBasePath := Value;
end;

procedure TConfig.Setcache_max_age(const Value: string);
begin
  Fcache_max_age := Value;
end;

procedure TConfig.SetCompress(const Value: string);
begin
  FCompress := Value;
end;

procedure TConfig.Setconfig_path(const Value: string);
begin
  Fconfig_path := Value;
end;

procedure TConfig.SetCorss_Origin(const Value: TCorss_Origin);
begin
  FCorss_Origin := Value;
end;

procedure TConfig.SetDBConfig(const Value: string);
begin
  FDBConfig := Value;
end;

procedure TConfig.Setdocument_charset(const Value: string);
begin
  Fdocument_charset := Value;
end;

procedure TConfig.SetError404(const Value: string);
begin
  FError404 := Value;
end;

procedure TConfig.SetError500(const Value: string);
begin
  FError500 := Value;
end;

procedure TConfig.SetHTTPQueueLength(const Value: Integer);
begin
  FHTTPQueueLength := Value;
end;

procedure TConfig.SetJsonToLower(const Value: Boolean);
begin
  FJsonToLower := Value;
end;

procedure TConfig.SetleftFmt(const Value: string);
begin
  FleftFmt := Value;
end;

procedure TConfig.Setmime_path(const Value: string);
begin
  Fmime_path := Value;
end;

procedure TConfig.Setopen_cache(const Value: boolean);
begin
  Fopen_cache := Value;
end;

procedure TConfig.Setopen_debug(const Value: Boolean);
begin
  Fopen_debug := Value;
end;

procedure TConfig.Setopen_log(const Value: Boolean);
begin
  Fopen_log := Value;
end;

procedure TConfig.setParams(json: IJObject);
var
  server_jo, Config_jo, corss_jo, dbconfig_jo, winservice_jo, redis_jo: TJSONObject;
  directory_jo: TJSONArray;
  corss: TCorss_Origin;
  i: integer;
  jo: TJSONObject;
  path: string;
  permission: Boolean;
  tm_redis: TRedisParams;
begin
  if json.O.GetValue('AppTitle') <> nil then
    AppTitle := json.O.GetValue('AppTitle').Value;
  server_jo := json.O.GetValue('Server') as TJSONObject;
  if server_jo <> nil then
  begin
    if server_jo.GetValue('Port') <> nil then
      Port := server_jo.GetValue('Port').Value;
    if server_jo.GetValue('Compress') <> nil then
      Compress := server_jo.GetValue('Compress').Value;
    if server_jo.GetValue('HTTPQueueLength') <> nil then
      HTTPQueueLength := server_jo.GetValue('HTTPQueueLength').Value.ToInteger;
    if server_jo.GetValue('ChildThreadCount') <> nil then
      ThreadCount := server_jo.GetValue('ChildThreadCount').Value.ToInteger;
  end;
  // redis参数设置
  redis_jo := json.O.GetValue('Redis') as TJSONObject;
  if redis_jo <> nil then
  begin

    if redis_jo.GetValue('Host') <> nil then
      tm_redis.Host := redis_jo.GetValue('Host').Value;
    if redis_jo.GetValue('Port') <> nil then
      tm_redis.Port := redis_jo.GetValue('Port').Value.ToInteger();
    if redis_jo.GetValue('PassWord') <> nil then
      tm_redis.PassWrod := redis_jo.GetValue('PassWord').Value;
    if redis_jo.GetValue('InitSize') <> nil then
      tm_redis.InitSize := redis_jo.GetValue('InitSize').Value.ToInteger;
    if redis_jo.GetValue('TimeOut') <> nil then
      tm_redis.TimeOut := redis_jo.GetValue('TimeOut').Value.ToInteger;
    if redis_jo.GetValue('ReadTimeOut') <> nil then
      tm_redis.ReadTimeOut := redis_jo.GetValue('ReadTimeOut').Value.ToInteger;
    redis := tm_redis;
  end;
 // config文件解析
  Config_jo := json.O.GetValue('Config') as TJSONObject;
  //log(Config_jo.ToJSON);
  if Config_jo <> nil then
  begin
    if Config_jo.GetValue('auto_start') <> nil then
      auto_start := Config_jo.GetValue('auto_start').Value = 'true';
    if Config_jo.GetValue('APP') <> nil then
      APP := Config_jo.GetValue('APP').Value;
    if Config_jo.GetValue('WebRoot') <> nil then
      WebRoot := Config_jo.GetValue('WebRoot').Value;
    if Config_jo.GetValue('template') <> nil then
      template := Config_jo.GetValue('template').Value;
    if Config_jo.GetValue('template_type') <> nil then
      template_type := Config_jo.GetValue('template_type').Value;
    if Config_jo.GetValue('document_charset') <> nil then
      document_charset := Config_jo.GetValue('document_charset').Value;
    if Config_jo.GetValue('open_log') <> nil then
      open_log := Config_jo.GetValue('open_log').Value = 'true';
    if Config_jo.GetValue('open_cache') <> nil then
      open_cache := Config_jo.GetValue('open_cache').Value = 'true';
    if Config_jo.GetValue('open_debug') <> nil then
      open_debug := Config_jo.GetValue('open_debug').Value = 'true';
    if Config_jo.GetValue('sessoin_name') <> nil then
      sessoin_name := Config_jo.GetValue('sessoin_name').Value;
    if Config_jo.GetValue('cache_max_age') <> nil then
      cache_max_age := Config_jo.GetValue('cache_max_age').Value;
    if Config_jo.GetValue('session_timer') <> nil then
      session_timer := Config_jo.GetValue('session_timer').Value.ToInteger;
    if Config_jo.GetValue('suffix') <> nil then
      suffix := Config_jo.GetValue('suffix').Value;
    if Config_jo.GetValue('JsonToLower') <> nil then
      JsonToLower := Config_jo.GetValue('JsonToLower').Value.ToBoolean;
    if Config_jo.GetValue('leftFmt') <> nil then
      leftFmt := Config_jo.GetValue('leftFmt').Value;
    if Config_jo.GetValue('rightFmt') <> nil then
      rightFmt := Config_jo.GetValue('rightFmt').Value;
  end;
  //跨域访问设置
  with corss do
  begin
    Allow_Origin := '';
    Allow_Headers := '';
    Allow_Method := '';
    Allow_Credentials := false;
  end;
  Corss_Origin := corss;
  corss_jo := Config_jo.GetValue('Corss_Origin') as TJSONObject;
  if corss_jo <> nil then
  begin
    corss.Allow_Origin := corss_jo.GetValue('Allow_Origin').Value;
    corss.Allow_Headers := corss_jo.GetValue('Allow_Headers').Value;
    corss.Allow_Method := corss_jo.GetValue('Allow_Method').Value;
    corss.Allow_Credentials := corss_jo.GetValue('Allow_Credentials').Value = 'true';
    Corss_Origin := corss;
  end;
  dbconfig_jo := json.O.GetValue('DBConfig') as TJSONObject;
  if dbconfig_jo <> nil then
  begin
    DBConfig := dbconfig_jo.ToJSON;
  end;
  //Windows服务设置
  winservice_jo := json.O.GetValue('WinService') as TJSONObject;
  if winservice_jo <> nil then
  begin
    WinServiceConfig := winservice_jo.ToJSON;
  end;

  //访问目录权限控制
  directory_permission.Clear;
  directory_jo := Config_jo.GetValue('directory') as TJSONArray;
  if (directory_jo <> nil) and (directory_jo.Count > 0) then
  begin
    for i := 0 to directory_jo.Count - 1 do
    begin
      try
        jo := directory_jo.Items[i] as TJSONObject;
        path := jo.GetValue('path').Value;
        path := path.Replace('\', '/');
        if (path.Substring(0, 1) <> '/') then
          path := '/' + path;
        if (path.Substring(path.Length - 1, 1) <> '/') then
          path := path + '/';
        permission := jo.GetValue('permission').Value.ToLower = 'true';
        directory_permission.Add(path, permission);
      except
        log('directory参数错误,服务启动失败');
        break;
      end;
    end;
  end;
end;

procedure TConfig.setPassword(password: string);
begin
  password_key := password;
end;

procedure TConfig.Setpassword_key(const Value: string);
begin
  Fpassword_key := Value;
end;

procedure TConfig.SetPort(const Value: string);
begin
  FPort := Value;
end;

procedure TConfig.Setredis(const Value: TRedisParams);
begin
  Fredis := Value;
end;

procedure TConfig.SetrightFmt(const Value: string);
begin
  FrightFmt := Value;
end;

procedure TConfig.Setroute_suffix(const Value: string);
begin
  Froute_suffix := Value;
end;

procedure TConfig.Setsession_start(const Value: Boolean);
begin
  Fsession_start := Value;
end;

procedure TConfig.Setsession_timer(const Value: Integer);
begin
  Fsession_timer := Value;
end;

procedure TConfig.Setsessoin_name(const Value: string);
begin
  Fsessoin_name := Value;
end;

procedure TConfig.Setshow_sql(const Value: Boolean);
begin
  Fshow_sql := Value;
end;

procedure TConfig.Settemplate(const Value: string);
begin
  Ftemplate := Value;
end;

procedure TConfig.Settemplate_type(const Value: string);
begin
  Ftemplate_type := Value;
end;

procedure TConfig.SetThreadCount(const Value: Integer);
begin
  FThreadCount := Value;
end;

procedure TConfig.SetWebRoot(const Value: string);
begin
  FWebRoot := Value;
end;

procedure TConfig.SetWinServiceConfig(const Value: string);
begin
  FWinServiceConfig := Value;
end;

initialization
  Config := TConfig.Create();

finalization
  Config.Free;

end.

