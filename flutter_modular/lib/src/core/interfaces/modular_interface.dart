import 'package:flutter/material.dart';

import '../../../flutter_modular.dart';

abstract class ModularInterface {
  IModularNavigator? navigatorDelegate;

  bool get debugMode;
  ModularFlags get flags;
  ModularArguments? get args;
  String get initialRoute;
  Module get initialModule;
  void setPathInActiveModules(String currentValue, String newValue);
  @visibleForTesting
  void overrideBinds(List<Bind> binds);
  void init(Module module);
  void bindModule(Module module, {String path, bool rebindDuplicates});
  void debugPrintModular(String text);
  T bind<T extends Object>(Bind<T> bind);
  Future<void> isModuleReady<M>();
  Future<B> getAsync<B extends Object>({List<Type>? typesInRequestList});

  IModularNavigator get to;
  B get<B extends Object>({
    List<Type>? typesInRequestList,
    B? defaultValue,
  });

  void addCoreInit(Module module);

  void removeModule(Module module);

  bool dispose<B extends Object>();

  bool isSingleton<T extends Object>(T bind);
}
