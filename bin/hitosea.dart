import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {

  // 创建 ArgParser 实例
  final parser = ArgParser();

  // 添加可选参数
  // parser.addFlag('n');

  parser.addOption("name", help: "请传入大驼峰类名(比如 TestName)");
  parser.addFlag("genderClassDir", abbr: "g", defaultsTo: false, help: "是否要生成类名文件夹");
  parser.addFlag("help", abbr: "h", defaultsTo: false, help: "帮助信息");

  // 解析命令行参数
  final results = parser.parse(args);
  final gcd = results["genderClassDir"] as bool;
  final help = results["help"] as bool;

  if (help) {
    showHelp(parser);
    return;
  }

  // 获取参数值
  if (results['name'] is! String) {
    showHelp(parser);
    return;
  }

  final name = results['name'] as String;
  if (name.isEmpty) {
    showHelp(parser);
    return;
  }

  final path = Directory.current.path;
  gender(name, path, gcd);
}

void gender(String className, String dirPath, bool genderClassDir) {
  if (className.isEmpty) {
    return;
  }

  try {
    // 类名文件夹
    final snakeName = camelToSnake(className);
    var dir = Directory(dirPath);
    if (genderClassDir) {
      dir = Directory(p.join(dirPath, snakeName));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }

    // 创建文件夹
    createDirSync(dir.path, "api");
    createDirSync(dir.path, "bindings");
    createDirSync(dir.path, "controller");
    createDirSync(dir.path, "model");
    createDirSync(dir.path, "repository");
    createDirSync(dir.path, "service");
    createDirSync(dir.path, "widgets");

    // 创建文件
    createFileSync(p.join(dir.path, "api", "${snakeName}_api.dart"), '''
class ${className}Api {
  
}
''');
    createFileSync(p.join(dir.path, "bindings", "${snakeName}_binding.dart"), getBindingString(className));
    createFileSync(p.join(dir.path, "controller", "${snakeName}_controller.dart"), getControllerString(className));
    createFileSync(p.join(dir.path, "model", "${snakeName}_model.dart"), getModelString(className));
    createFileSync(p.join(dir.path, "repository", "${snakeName}_repository.dart"), getRepositoryString(className));
    createFileSync(p.join(dir.path, "repository", "${snakeName}_repository_impl.dart"), getRepositoryImplString(className));
    createFileSync(p.join(dir.path, "repository", "${snakeName}_repository_mock.dart"), getRepositoryMockString(className));
    createFileSync(p.join(dir.path, "service", "${snakeName}_service.dart"), getServiceString(className));
    // createFileSync(p.join(dir.path, "widgets", "${snakeName}_widgets.dart"), "// 编写自定义组件");
    createFileSync(p.join(dir.path, "${snakeName}_get_page.dart"), getGetPageString(className));
    createFileSync(p.join(dir.path, "${snakeName}_view.dart"), getViewString(className));

  } catch (e) {
    print('失败: $e');
    print("请输入 -h 查看帮助");
    rethrow;
  }
}

void showHelp(ArgParser parser) {
  print("${parser.usage}\n\n示例 hitosea --name=TestName");
}

/// 将驼峰命名转换为蛇形命名（下划线分隔的小写命名）
String camelToSnake(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'([A-Z])'), (match) {
    return '_${match.group(1)!.toLowerCase()}';
  }).replaceFirst('_', '').toLowerCase();
}


/// 将大驼峰命名转换为小驼峰命名
String upperCamelToLowerCamel(String upperCamelCase) {
  if (upperCamelCase.isEmpty) return '';
  // 将第一个字符转换为小写
  return upperCamelCase[0].toLowerCase() + upperCamelCase.substring(1);
}

void createDirSync(String path, String name) {
  final dir = Directory(p.join(path, name));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

void createFileSync(String path, String content) {
  File file = File(path);
  // 写入文本内容，mode 参数可选，默认是覆盖写入
  file.writeAsStringSync(content, mode: FileMode.write);
}

String getBindingString(String className) {
  final snakeName = camelToSnake(className);

  return '''
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../controller/${snakeName}_controller.dart';
import '../repository/${snakeName}_repository.dart';
import '../repository/${snakeName}_repository_mock.dart';
import '../repository/${snakeName}_repository_impl.dart';
import '../service/${snakeName}_service.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    ${className}Repository repository = kDebugMode ? ${className}RepositoryMock() : ${className}RepositoryImpl();

    Get.put(${className}PageController(service: ${className}Service(repository)));
  }
}
    ''';
}

String getControllerString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import 'package:get/get.dart';
import '../service/${snakeName}_service.dart';

class ${className}PageController extends GetxController {
  ${className}PageController({ required this.service });

  final ${className}Service service;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
    ''';
}


String getModelString(String className) {
  // final snakeName = camelToSnake(className);
  return '''
class ${className}Model {
  
  var id = "";
  
  ${className}Model(this.id);
}
    ''';
}

String getRepositoryString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import '../model/${snakeName}_model.dart';

abstract class ${className}Repository {
  
  /// 获取地址列表
  Future<List<${className}Model>> getList();
}
    ''';
}

String getRepositoryImplString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import '../model/${snakeName}_model.dart';
import '${snakeName}_repository.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  @override
  Future<List<${className}Model>> getList() {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
    ''';
}

String getRepositoryMockString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import '../model/${snakeName}_model.dart';
import '${snakeName}_repository.dart';

class ${className}RepositoryMock implements ${className}Repository {
  @override
  Future<List<${className}Model>> getList() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [${className}Model("1"), ${className}Model("2")];
  }
}
    ''';
}

String getServiceString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import 'package:get/get.dart';

import '../model/${snakeName}_model.dart';
import '../repository/${snakeName}_repository.dart';

class ${className}Service {
  ${className}Repository repository;

  ${className}Service(this.repository);

  RxList<${className}Model> dataList = <${className}Model>[].obs;

  Future<List<${className}Model>> getList() async {
    dataList.value = await repository.getList();
    // 把网络数据写到缓存
    return dataList;
  }

  Future<List<${className}Model>> getListCache() async {
    // 写读本地缓存
    return dataList;
  }
}
    ''';
}

String getGetPageString(String className) {
  final snakeName = camelToSnake(className);
  final lowerCamelName = upperCamelToLowerCamel(className);
  return '''
import 'package:get/get.dart';

import '${snakeName}_view.dart';
import 'bindings/${snakeName}_binding.dart';
import '../../config/app_page.dart';
import '../../routers/name.dart';

class ${className}Page implements AppPage {

  ${className}Page({this.name = RouteNames.$lowerCamelName 如果没有，记得去更改name});
  final String name;

  @override
  GetPage get page => GetPage(
    name: RouteNames.$lowerCamelName 如果没有，记得去更改name,
    page: () => const ${className}View(),
    transition: Transition.fadeIn,
    binding: ${className}Binding(),
  );
}
    ''';
}

String getViewString(String className) {
  final snakeName = camelToSnake(className);
  return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/${snakeName}_controller.dart';

class ${className}View extends StatefulWidget {
  const ${className}View({super.key});

  @override
  State<${className}View> createState() => _${className}State();
}

class _${className}State extends State<${className}View> {
  final controller = Get.find<${className}PageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hitosea $className'),
      ),
      body: Text("Hello $className"),
    );
  }
}
    ''';
}
