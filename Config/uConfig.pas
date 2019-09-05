unit uConfig;

interface

const
  __APP__ = '';                               // 应用名称 ,可当做虚拟目录使用
  template = 'view';                        // 模板根目录
  template_type = '.html';                  // 模板文件类型
  roule_suffix = '.html';                     // 伪静态后缀文件名
  session_start = true;                     // 启用session
  session_timer = 30;                        // session过期时间分钟
  config = 'resources/config.json';         // 配置文件地址
  mime = 'resources/mime.json';             // mime配置文件地址
  package_config = 'resources/package.json';                // bpl包配置文件
  bpl_Reload_timer = 5;                                     // bpl包检测时间间隔 默认5秒
  bpl_unload_timer = 10;                                    // bpl包卸载时间间隔 默认10秒，加载新包后等待10秒卸载旧包
  open_package = false;                                      // 使用 bpl包开发模式
  open_log = true;                          // 开启日志;open_debug=true并开启日志将在UI显示
  open_cache = true;                        // 开启缓存模式open_debug=false时有效
  cache_max_age = '315360000';                // 缓存超期时长秒
  open_interceptor = true;                 // 开启拦截器
  document_charset = 'utf-8';               // 字符集
  password_key = '';                        // 配置文件秘钥设置,为空时不启用秘钥,结合加密工具使用.
  show_sql = false;                            //日志打印sql
  open_debug = false;                       // 开发者模式缓存功能将会失效,开启前先清理浏览器缓存
implementation

end.

