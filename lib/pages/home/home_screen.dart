import 'package:flutter/material.dart';
import 'home_controller.dart';

import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliverAppBar(
        centerTitle: false,
        expandedHeight: 160,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          title: Text("Hello World"),

        ),
      ),
    );
  }
}
