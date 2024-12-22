# flutter_base
# base-flutter 介绍

参考：

[https://juejin.cn/post/6950514701969129486#heading-3](https://juejin.cn/post/6950514701969129486#heading-3)

学习 Flutter 也有一个月的时间了，现在觉得也没有这么困难，开始学会了封装 Widget、抽象 Function 等等，没有啥不兼容的情况，如果下载下来的代码跑不动，试试把对应平台的文件，比如 Android 删掉，再 create 一下问题就解决了。

第一个上手的项目是学校里开源的 pda 代码，动不动七八百行的代码真的非常让人头痛，而且注释也很少...我想借这个机会把状态管理，网络 io 好好学习一下，我觉得一个中大型项目需要有一个统一的状态管理、网络 IO 管理，组件管理、路由管理等等，分开来写更容易维护并且有利于团队的协作，在偶然间学习到了 GetX 框架，发现确实是一个非常好用的框架，把页面的 screen、controller 还有 binding 全部都分开了，虽然一个页面要写三个文件，但是把逻辑很好的全部分离了，并且还自带非常方便的路由管理器，用起来肥肠的舒服。

我在网上找了好久，也没有一个 Flutter 的启动框架，包含了基础的框架结构的代码，所以我打算在使用这些技术的基础上再写一个脚手架，下次有新项目直接把现在的脚手架下载下来就能开箱即用了！

并且附带代码对应的开发手册和讲解。

建议先 clone 到本地然后再看代码结构解析。

# GetX 是什么？如何使用？

GetX 是 Flutter 上的一个轻量且强大的解决方案：高性能的状态管理、智能的依赖注入和便捷的路由管理。

GetX 有 3 个基本原则：

- **性能：** GetX 专注于性能和最小资源消耗。GetX 打包后的 apk 占用大小和运行时的内存占用与其他状态管理插件不相上下。如果你感兴趣，这里有一个[性能测试](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fjonataslaw%2Fbenchmarks)。
- **效率：** GetX 的语法非常简捷，并保持了极高的性能，能极大缩短你的开发时长。
- **结构：** GetX 可以将界面、逻辑、依赖和路由完全解耦，用起来更清爽，逻辑更清晰，代码更容易维护。

GetX 并不臃肿，却很轻量。如果你只使用状态管理，只有状态管理模块会被编译，其他没用到的东西都不会被编译到你的代码中。它拥有众多的功能，但这些功能都在独立的容器中，只有在使用后才会启动。

步骤一：在你的 MaterialApp 前添加 "Get"，将其变成 GetMaterialApp。

```python
**void** **main**() => **runApp**(GetMaterialApp(home: Home()));
```

步骤二：创建你的业务逻辑类，并将所有的变量，方法和控制器放在里面。 你可以使用一个简单的".obs "使任何变量成为可观察的。

```python
**class** **Controller** **extends** **GetxController**{
  **var** count = 0.obs;
  increment() => count++;
}
```

步骤三：创建你的界面，使用 StatelessWidget 节省一些内存，使用 Get 你可能不再需要使用 StatefulWidget。

```python
class Home extends StatelessWidget {

  @override
  Widget build(context) {

    // 使用Get.put()实例化你的类，使其对当下的所有子路由可用。
    final Controller c = Get.put(Controller());

    return Scaffold(
      // 使用Obx(()=>每当改变计数时，就更新Text()。
      appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),

      // 用一个简单的Get.to()即可代替Navigator.push那8行，无需上下文！
      body: Center(child: ElevatedButton(
              child: Text("Go to Other"), onPressed: () => Get.to(Other()))),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: c.increment));
  }
}

class Other extends StatelessWidget {
  // 你可以让Get找到一个正在被其他页面使用的Controller，并将它返回给你。
  final Controller c = Get.find();

  @override
  Widget build(context){
     // 访问更新后的计数变量
     return Scaffold(body: Center(child: Text("${c.count}")));
  }
}
```

# 目录结构

我的习惯如下

```python
lib/
├─models 各种结构化实体类，我习惯按照页面的请求返回来进行分类
│  ├─home
│  └─login
├─pages  所有的页面文件都在这里
│  ├─home
│  ├─login
│  └─splash 
├─routes 路由模块
├─shared 全局共享文件夹，包括静态变量、全局services、utils、全局Widget等
│  ├─constants 常用文件
│  ├─services  服务注册比如SharedPreferences
│  ├─utils    工具类
├─theme 主题文件
├─widget 全部的组件
└─api 网络IO封装部分 
|- app_bindings.dart - 在app运行之前启动的服务等，如Restful api
|- di.dart - 全局依赖注入对象，如SharedPreferences等
|- main.dart - 导出类，用作外面调用api请求主入口
```

# 基础配置

我们看一下 main.dart 的配置

```python
void main() async {
  WidgetsFlutterBinding._ensureInitialized_(); 
  // 这里是把SharedPreferences注入到全局变量里面，会有这里的讲解
  await DenpendencyInjection._init_(); 

  // 获得app存储的路径，方便存储cookie等
  repo_general.supportPath = await getApplicationSupportDirectory();

  runApp(App());
  // 加载配置信息
  configLoading();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      // ！！！ 注入在页面里注入controller的对象
      initialBinding: AppBinding(),
      initialRoute: Routes._SPLASH_,
      defaultTransition: Transition.fade,
      getPages: AppPages._routes_,
      smartManagement: SmartManagement.keepFactory,
      title: 'Flutter GetX Boilerplate',
      theme: ThemeConfig._lightTheme_,
      locale: TranslationService._locale_,
      fallbackLocale: TranslationService._fallbackLocale_,
      translations: TranslationService(),
      builder: EasyLoading._init_(),
    );
  }
}
```

# 路由配置

a. 导航到下一个页面

```python
**Get**.toNamed("/NextScreen");
```

b. 浏览并删除前一个页面

```
**Get**.offNamed("/NextScreen");
```

c. 浏览并删除所有以前的页面

```python
**Get**.offAllNamed("/NextScreen");
```

好了，简单的介绍了一下 GetX 的路由功能，我们定义我们自己的路由模块。

a. app_routes.dart，定义路由名称，我们有根页面（splash），登录&注册选择页面、登录页面、注册页面和 home 页面。

```python
abstract class Routes {
  static const _SPLASH _= '/';

  static const _LOGIN _= '/login';

  static const _HOME _= '/home';
}
```

b. app_pages.dart，定义 GetX 的路由，我们注意到 GetPage 以及他所包含的参数，每一个 GetPage 都是一个路由定义，每一个路由定义包含了 name 名称、page 页面和 binding 依赖，这样我们就把依赖绑定到指定的路由了，每个路由都会有指定的依赖，当然我们也可以加入 global 的 initialBinding，这个依赖是全局的依赖，我们后面在 main 入口文件里面会讲到。

# 加入欢迎页面

一般我们的项目中都会加一个 Splash 页面，这个页面的作用类似于欢迎页，在此项目中这个页面的作用是判断当前用户是否登录，如果没有登录则进入登录&注册选择页面，否则直接进入 Home 页面。

Splash 模块包含下面 4 个文件，后面我们的每个模块都会至少包含这几个文件，这个是参考了 GetX 的[示例](https://github.com/jonataslaw/getx/blob/master/example/lib/main.dart)做了一些自己的习惯改动而成。

```python
|- Splash - Splash模块文件夹  
|- splash_binding.dart - Splash依赖绑定文件，也就是这个模块依赖的Controller，Service都可以在这里注入进去。 
|- splash_controller.dart - Controller文件主要处理当前模块的业务逻辑，应该把所有的业务逻辑写在这里面，保证UI与业务完全分离。  
|- splash_screen.dart - 当前模块的页面UI文件。   
|- splash.dart - Splash模块的导出文件，导出这个模块下面的所有文件，方便引用。
```

a. splash_binding.dart，splash 模块我们只要依赖 Controller，所以利用 Get.put 加进去即可，这样后面可以通过 Get.find()来引入这个 Controller。

```python
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
```

b. splash_controller.dart，Controller 通过判断 token 是否存在来判断是否登录。注意这里的跳转我们用到了 [Get.toNamed()](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fjonataslaw%2Fgetx%2Fblob%2Fmaster%2Fdocumentation%2Fzh_CN%2Froute_management.md)方法，有没有发现这里不需要 context 了，是的，GetX 并不需要！另外，这里我们额外用了一个 delay 来模拟一些耗时操作，比如你需要请求后台 api 拿一些基础数据等。

```dart
class SplashController extends GetxController {
  @override
  void onReady() async {
    super.onReady();
    await Future.delayed(Duration(milliseconds: 2000));
    var storage = Get.find<SharedPreferences>();
    try {
      if (storage.getString(StorageConstants._cookie_) != null) {
        Get.toNamed(Routes._HOME_);
      } else {
        Get.toNamed(Routes._LOGIN_);
      }
    } catch (e) {
      Get.toNamed(Routes._LOGIN_);
    }
  }
}
```

c. splash_screen.dart，splash 页面我们就用了一个简单的 loading。

```dart
class SplashScreen extends StatelessWidget {
  @override  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: Colors._white_,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons._hourglass_bottom_,
            color: ColorConstants._darkGray_,
            size: 30.0,
          ),
          Text(
            'loading...',
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }
}
```

d. splash.dart，导出当前模块所有文件。

```dart
**export** 'splash_binding.dart';
**export** 'splash_controller.dart';
**export** 'splash_screen.dart';
```

# 加入 api 模块

Api 模块我们使用了免费的 Restful api [REQ|RES](https://link.juejin.cn?target=https%3A%2F%2Freqres.in%2F) 来模拟我们的业务登录、注册和用户信息等。同时我们使用了 GetX 内置的 http 模块来构建 Api 模块，我们添加了 provider、repository、inteceptors 等，这里因为是 GetX 模板项目，我们没有按照模块区分 api。

a. base_provider.dart，提供拦截器 inteceptors 的功能，provider 可以继承 base_provider.dart 来初始化拦截器。

```dart
class BaseProvider extends GetConnect {
  @override  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.addAuthenticator(authInterceptor);
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
  }
}
```

b. api_provider.dart，这里只有 Restful api，也可以添加 db_provider.dart，cache_provider.dart 等。我们这里继承了 BaseProvider，这样在第一次调用后天接口之前，我们会添加上述的 3 个拦截器。

```dart
class ApiProvider extends BaseProvider {
  Future<Response> login(String path, LoginRequest data) {
    return post(path, data.toJson());
  }

}
```

c. api_repository.dart，处理数据，这个类中我们只处理成功的请求，失败的都交给了拦截器。

```dart
class ApiRepository {
  ApiRepository({required this.apiProvider});
  final ApiProvider apiProvider;
  Future<LoginResponse?> login(LoginRequest data) async {
    final res = await apiProvider.login('/api/login', data);
    if (res.statusCode == 200) {
      return LoginResponse.fromJson(res.body);
    }
  }

}
```

# 报错

如果报错

```dart
Execution failed for task ':path_provider_android:compileDebugJavaWithJavac'.
> Could not resolve all files for configuration ':path_provider_android:androidJdkImage'.
   > Failed to transform core-for-system-modules.jar to match attributes {artifactType=_internal_android_jdk_image, org.gradle.libraryelements=jar, org.gradle.usage=java-runtime}.
      > Execution failed for JdkImageTransform: D:\JDK\Android\SDK34\platforms\android-34\core-for-system-modules.jar.
         > Error while executing process D:\software\Androidstudio\jbr\bin\jlink.exe with arguments {--module-path C:\Users\xiaow\.gradle\caches\transforms-3\4a46fc89ed5f9adfe3afebf74eb8bfeb\transformed\output\temp\jmod --add-modules java.base --output C:\Users\xiaow\.gradle\caches\transforms-3\4a46fc89ed5f9adfe3afebf74eb8bfeb\transformed\output\jdkImage --disable-plugin system-modules}
```

则在android/settings.gradle中的plugins中更改下列版本即可
```
    id "com.android.application" version "8.3.2" apply false
```