unit MVC.Config;

interface

type
  TConfig = record
    __APP__: string;                               // 应用名称 ,可当做虚拟目录使用
    __WebRoot__:string;                     //根目录
    template: string;                     // 模板根目录
    template_type: string;                  // 模板文件类型
    roule_suffix: string;                     // 伪静态后缀文件名
    session_name: string;
    session_start: Boolean;                     // 启用session
    session_timer: Integer;                        // session过期时间分钟
    config: string;         // 配置文件地址
    mime: string;             // mime配置文件地址
    package_config: string;                // bpl包配置文件
    bpl_Reload_timer: Integer;                                     // bpl包检测时间间隔 默认5秒
    bpl_unload_timer: Integer;                                    // bpl包卸载时间间隔 默认10秒，加载新包后等待10秒卸载旧包
    open_package: Boolean;                                      // 使用 bpl包开发模式
    open_log: Boolean;                          // 开启日志;open_debug=true并开启日志将在UI显示
    open_cache: Boolean;                        // 开启缓存模式open_debug=false时有效
    cache_max_age: string;                // 缓存超期时长秒
    open_interceptor: Boolean;                 // 开启拦截器
    document_charset: string;               // 字符集
    password_key: string;                        // 配置文件秘钥设置,为空时不启用秘钥,结合加密工具使用.
    show_sql: Boolean;                            //日志打印sql
    open_debug: Boolean;                       // 开发者模式缓存功能将会失效,开启前先清理浏览器缓存
    Error404:string;
    Error500:string;
		JsonToLower:boolean;// 返回json数据以小写形式显示
  end;

var
  Config: TConfig;

implementation

end.

