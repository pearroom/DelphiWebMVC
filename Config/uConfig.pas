unit uConfig;

interface

uses
  DBMySql, DBSQLite, DBMSSQL, DBMSSQL12, DBOracle;

type
  TDB = TDBSQLite;                // TDBMySql,TDBSQLite,TDBMSSQL,TDBMSSQL12(2012版本以上),TDBOracle

const
  db_type = 'SQLite';             // MYSQL,SQLite,MSSQL,ORACLE
  db_start = true;                // 启用数据库
  template = 'view';              // 模板根目录
  template_type = '.html';        // 模板文件类型
  session_start = true;           // 启用session
  session_timer = 0;              // session过期时间分钟  0 不过期
  config = 'config.json';         // 配置文件地址
  open_log = true;                // 开启日志
  open_cache = true;              // 开启缓存模式open_debug=false时有效
  open_interceptor = true;        // 开启拦截器
  default_charset = 'utf-8';      // 字符集
  password_key = '';              // 配置文件秘钥设置,为空时不启用秘钥,结合加密工具使用.

  open_debug = False;              // 开发者模式缓存功能将会失效,开启前先清理浏览器缓存

implementation

end.

