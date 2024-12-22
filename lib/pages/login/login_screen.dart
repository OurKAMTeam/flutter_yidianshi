import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'login_controller.dart';
class LoginScreen extends GetView<LoginController>{
  //final xdLoginController controller = Get.arguments;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              const SizedBox(height: 160,),

              Center( // 使用 Center 组件居中
                child: Text(
                  "登录入口",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primaryContainer
                  ),
                ),
              ),

              const SizedBox(height:  60.0),

              _buildForms(context),
            ],
          )
      ),
    );
  }


  Widget _buildForms(BuildContext context) {
    return Form(
        key: controller.loginFormKey,
        child: Column(
          children: [
            TextField(
              controller: controller.loginEmailController,
              decoration:  InputDecoration(
                  labelText: "请输入学号",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/login/number.png",
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none
                  )
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: controller.loginPasswordController,
              decoration:  InputDecoration(
                  labelText: "请输入学号",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/login/passwd.png",
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none
                  )
              ),
            ),

            const SizedBox(height: 12.0),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Text("本科生"),
            //     Radio(
            //         value: "undergraduate",
            //         groupValue: this._selectedOption,
            //         activeColor: Colors.blue,
            //         onChanged: (value){
            //           setState(() {
            //             this._selectedOption = value!;
            //           });
            //         }
            //     ),
            //     SizedBox(width: 20),
            //     Text("研究生"),
            //     Radio(
            //         value: "graduate",
            //         groupValue: this._selectedOption,
            //         activeColor: Colors.blue,
            //         onChanged: (value){
            //           setState(() {
            //             this._selectedOption = value!;
            //           });
            //         }
            //     ),
            //   ],
            //
            // ),
            const SizedBox(height: 24.0),
            // 添加登录按钮
            ElevatedButton(
              onPressed: () {
                controller.login(context);
              },
              child:  Text(
                '登录',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                ),
              ),
              style: ElevatedButton.styleFrom(
                //fixedSize: Size(200, 50),
                fixedSize: const Size(200,50),
                backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 20),
          ],
        )
    );
  }


}
