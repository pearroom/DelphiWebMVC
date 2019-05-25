# DelphiWebMVC使用说明:
	版本:1.0
	运行时使用管理员权限。
	项目用到mORMot代码库,主页下载。
	项目主页：http://www.delphiwebmvc.com
	讨论QQ群: 685072623

	开发工具:delphi xe10.2 
	注意:win10系统以管理员权限运行
	数据库支持MySQL,SQLite,MSSQL,Oracle,其它数据库可自行进行添加。
	
	Controller  : 控制器类存放目录
	Common 		: 框架相关代码
	Config 		: 项目配置相关代码
	Module 		: 数据库引擎及webbroker服务代码
	Syn 		: https.sys相关类库
	Publish 	: 视图页面js,css,html,数据库配置相关资源
	Project 	: 工程文件
	
	数据库与服务配置(可加密配置)：
	Publish/config.json文件
	例：
	{
	"Server": {
		"Port": "8004",
		"Compress":"deflate",
		"HTTPQueueLength":1000,
		"ChildThreadCount":10
	},
	"Redis":{
		"Host":"",
		"Port":6379,
		"PassWord":"admin",
		"InitSize":5,
		"TimeOut":60,
		"ReadTimeOut":10
	},
	"DBConfig":{
		"MYSQL": {
			"DriverID": "MySQL",
			"Server": "127.0.0.1",
			"Port": "3306",
			"Database": "test",
			"User_Name": "root",
			"Password": "root",
			"CharacterSet": "utf8",
			"Compress": "False",
			"Pooled": "True",
			"POOL_CleanupTimeout": "30000",
			"POOL_ExpireTimeout": "90000",
			"POOL_MaximumItems": "50"
		},
		"SQLite": {
			"DriverID": "SQLite",
			"Database": "sqlite.db",
			"User_Name": "",
			"Password": "",
			"OpenMode": "CreateUTF8",
			"Pooled": "True",
			"POOL_CleanupTimeout": "30000",
			"POOL_ExpireTimeout": "90000",
			"POOL_MaximumItems": "50"
		},
		"MSSQL": {
			"DriverID": "MSSQL",
			"Server": "127.0.0.1",
			"Port": "1433",
			"Database": "Northwind",
			"User_Name": "sa",
			"Password": "",
			"Pooled": "True",
			"POOL_CleanupTimeout": "30000",
			"POOL_ExpireTimeout": "90000",
			"POOL_MaximumItems": "50"
		},
		"ORACLE": {
			"DriverID": "Ora",
			"CharacterSet": "UTF8",
			"Database": "192.168.178.102:1521\\orcl",
			"User_Name": "",
			"Password": "",
			"Pooled": "True",
			"POOL_CleanupTimeout": "30000",
			"POOL_ExpireTimeout": "90000",
			"POOL_MaximumItems": "50"
		}
	}
}

	框架各项参数设置：
	unit uConfig;

	interface

	const
	  __APP__='Admin';            				// 应用名称 ,可当做虚拟目录使用
	  template = 'view';                        // 模板根目录
	  template_type = '.html';                  // 模板文件类型
	  session_start = true;                     // 启用session
	  session_timer = 0;                        // session过期时间分钟  0 不过期
	  config = 'resources/config.json';         // 配置文件地址
	  mime = 'resources/mime.json';             // mime配置文件地址
	  open_log = true;                          // 开启日志;open_debug=true并开启日志将在UI显示
	  open_cache = true;                        // 开启缓存模式open_debug=false时有效
	  open_interceptor = true;                  // 开启拦截器
	  default_charset = 'utf-8';                // 字符集
	  password_key = '';                        // 配置文件秘钥设置,为空时不启用秘钥,结合加密工具使用.
	  open_debug = false;                        // 开发者模式缓存功能将会失效,开启前先清理浏览器缓存

	implementation

	end.
	
	数据库引用
	unit uDBConfig;

	interface

	uses
	  DBSQLite, DBMySql;

	type
	  TDBConfig = class
	  public
		Default: TDBSQLite;   //必须有Default成员变量名
		MYSQL: TDBMySql;
		constructor Create;
		destructor Destroy; override;
	  end;

	implementation

	{ TDBConfig }

	constructor TDBConfig.Create;
	begin
	  Default := TDBSQLite.Create('SQLite');
	  MYSQL := TDBMySql.Create('MYSQL');
	end;

	destructor TDBConfig.Destroy;
	begin
	  Default.Free;
	  MYSQL.Free;
	  inherited;
	end;

	end.

	路由配置：
	Config/uRouleMap.pas配置相关路由
	例:
	unit uRouleMap;

	interface

	uses
	  Roule;

	type
	  TRouleMap = class(TRoule)
	  public
		constructor Create(); override;
	  end;

	implementation

	uses
	  MainController, CaiWuController, FirstController, IndexController, KuCunController, LoginController, UsersController, XiaoShouController;

	constructor TRouleMap.Create;
	begin
	  inherited;
	//路径,控制器,视图目录,是否拦截
	  SetRoule(name: string; ACtion: TClass; path: string = '';isInterceptor:Boolean=True);
	  SetRoule('', TLoginController, 'login');
	  SetRoule('Main', TMainController, 'main');
	  SetRoule('Users', TUsersController, 'users');
	end;

	end.


	控制器开发：
	存放在Controller文件夹
	例:
	unit LoginController;

	interface

	uses
	  System.SysUtils, System.Classes, FireDAC.Stan.Intf, Data.DB, superobject,
	  BaseController;

	type
	  TLoginController = class(TBaseController)
	  public
		procedure index();
		procedure check();
		procedure checknum();
	  end;

	implementation

	uses
	  uTableMap;

	procedure TLoginController.check();
	var
	  json: string;
	  sdata, ret, wh: ISuperObject;
	  username, pwd: string;
	  sql: string;
	begin
	  ret := SO();
	  with View do
	  begin
		try
		  username := Input('username');
		  pwd := Input('pwd');
		  Sessionset('username', username);
		  json := Sessionget('username');
		  wh := SO();
		  wh.S['username'] := username;
		  wh.S['pwd'] := pwd;
		  sdata := Db.FindFirst(tb_users, wh);
		  if (sdata <> nil) then
		  begin
			json := sdata.AsString;
			Sessionset('username', username);
			Sessionset('name', sdata.S['name']);
			ret.I['code'] := 0;
			ret.S['message'] := '登录成功';
		  end
		  else
		  begin
			ret.I['code'] := -1;
			ret.S['message'] := '登录失败';
		  end;
		  ShowJson(ret);
		except
		  on e: Exception do
			ShowText(e.ToString);
		end;

	  end;
	end;

	procedure TLoginController.checknum;
	var
	  num: string;
	begin
	  Randomize;
	  num := inttostr(Random(9)) + inttostr(Random(9)) + inttostr(Random(9)) + inttostr(Random(9));
	  View.ShowCheckIMG(num, 60, 30);
	end;

	procedure TLoginController.index();
	begin
	  with View do
	  begin
		ShowHTML('Login');
	  end;
	end;

	end.


	拦截器配置：
	Config/uInterceptor.pas
	例：
	unit uInterceptor;

	interface

	uses
	  System.SysUtils, View, System.Classes;

	type
	  TInterceptor = class
		urls: TStringList;
		function execute(View: TView; error: Boolean): Boolean;
		constructor Create;
		destructor Destroy; override;
	  end;

	implementation

	{ TInterceptor }

	constructor TInterceptor.Create;
	begin
	  urls := TStringList.Create;
	  //拦截器默认关闭状态uConfig文件修改
	  //不需要拦截的地址添加到下面
	  urls.Add('/');
	  urls.Add('/check');
	  urls.Add('/checknum');
	end;

	function TInterceptor.execute(View: TView; error: Boolean): Boolean;
	var
	  url: string;
	begin
	  Result := false;
	  with View do
	  begin
		if (error) then
		begin
		  Result := true;
		  exit;
		end;
		url := LowerCase(Request.PathInfo);
		if urls.IndexOf(url) < 0 then
		begin
		  if (SessionGet('username') = '') then
		  begin
			Result := true;
			Response.Content := '<script>window.location.href=''/'';</script>';
			Response.SendResponse;
		  end;
		end;
	  end;
	end;

	destructor TInterceptor.Destroy;
	begin
	  urls.Free;
	  inherited;
	end;

	end.


	
	框架标记：
	__APP__ 应用路径
    setAttr('ls',list.AsString);
    setAttr('key1','1');
    setAttr('key2','2');
	setAttr('key3','3');
    setAttr('username','admin');
    setAttr('user',jo.ToString);
	
	<#include file=/public.html>
	#{username}
	#{user.name}
	<#if key1 eq 1 and key2 eq 2 or key3 eq 3 >
	<div>
		<#list data=ls item=d>
			<span>#{d.name}</span>
			<#if d.sex eq 1>男 <#else if d.sex eq 0> 女 <#else> 未知  </#if><br>

		</#list>
	</div>
	<#else>
	   不存在
	</#if>
	
	条件类别
	'neq', '!=='	
	'eq', '=='
	'and', '&&'
	'or', '||'
	'gte', '>='
	'ge', '>='
	'gt', '>='
	'lte', '<='
	'le', '<='
	'lt', '<'