import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

import '../../presenters/inject.dart';
import '../errors/errors.dart';
import '../models/bind.dart';
import 'disposable.dart';
import 'modular_route.dart';

class _MutableValue {
  var isReadyFlag = false;
}

@immutable
abstract class Module {
  final _singletonBinds = <Type, dynamic>{};

  final List<Bind> _binds = [];
  List<Bind> get binds => const [];

  List<Bind> getProcessBinds() => _binds;
  List<ModularRoute> get routes => const [];

  List<Module> get imports => const [];
  final _mutableValue = _MutableValue();

  List<dynamic> get instanciatedSingletons => _singletonBinds.values.toList();

  Module() {
    _binds.addAll(binds);
    for (var module in imports) {
      final list = <Bind>[];
      for (var bind in module._binds.where((element) => element.export)) {
        list.add(bind);
      }
      _binds.insertAll(0, list);
    }
  }

  Future<void> isReady() async {
    if (_mutableValue.isReadyFlag) return;
    _mutableValue.isReadyFlag = true;
    final asyncBindList = _binds.whereType<AsyncBind>().toList();
    for (var bind in asyncBindList) {
      final resolvedBind = await bind.converToAsyncBind();
      _binds.insert(0, resolvedBind);
    }
  }

  void changeBinds(List<Bind> b) {
    _binds.clear();
    _binds.addAll(b);
  }

  final Set<String> paths = <String>{};

  T? getInjectedBind<T>([Type? type]) {
    type = type ?? _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      return _singletonBinds[type];
    } else {
      return null;
    }
  }

  T? getBind<T extends Object>({required List<Type> typesInRequest}) {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type];
      return bindValue;
    }

    var bind = _binds.firstWhere((b) => b.inject is T Function(Inject), orElse: () => BindEmpty());
    if (bind is BindEmpty) {
      typesInRequest.remove(type);
      return null;
    }

    if (typesInRequest.contains(type)) {
      throw ModularError('''
Recursive calls detected. This can cause StackOverflow.
Check the Binds of the $runtimeType module:
***
${typesInRequest.join('/n')}
***
      
      ''');
    } else {
      typesInRequest.add(type);
    }

    bindValue = bind.inject(Inject(typesInRequest: typesInRequest)) as T;
    if (bind.isSingleton) {
      _singletonBinds[type] = bindValue;
    }

    typesInRequest.remove(type);
    return bindValue;
  }

  /// Dispose bind from the memory
  bool remove<T>() {
    final type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      var inject = _singletonBinds[type];
      _callDispose(inject);
      _singletonBinds.remove(type);
      return true;
    } else {
      return false;
    }
  }

  _callDispose(dynamic bind) {
    if (bind is Disposable) {
      bind.dispose();
    } else if (bind is ChangeNotifier) {
      bind.dispose();
    } else if (bind is Sink) {
      bind.close();
    } else if (bind is Store) {
      bind.destroy();
    }
  }

  /// Dispose all bind from the memory
  void cleanInjects() {
    for (final key in _singletonBinds.keys) {
      var _bind = _singletonBinds[key];
      _callDispose(_bind);
    }
    _singletonBinds.clear();
  }

  Type _getInjectType<B>() {
    var foundType = B;
    _singletonBinds.forEach((key, value) {
      if (value is B) {
        foundType = key;
      }
    });

    return foundType;
  }

  /// Create a instance of all binds isn't lazy Loaded
  void instance(List<dynamic> singletons) {
    final _filtedBinds = List<Bind>.from(_binds)..removeWhere((e) => _removeBindFromInstacedSingletons(e, singletons));

    for (final bindElement in _filtedBinds) {
      if (!bindElement.isLazy) {
        var b = bindElement.inject(Inject());
        _singletonBinds[b.runtimeType] = b;
      }
    }
  }

  bool _removeBindFromInstacedSingletons(Bind<Object> bind, List<dynamic> singletons) {
    if (bind.isLazy) {
      return false;
    }
    var remove = false;
    for (var singleton in singletons) {
      remove = _existBind(singleton, bind.inject);
      if (remove) {
        break;
      }
    }
    return remove;
  }

  bool _existBind<T>(T instance, T Function(Inject<dynamic>) inject) {
    // ignore: unnecessary_type_check
    return inject is T Function(Inject);
  }
}

extension ModuleHelper on Module {
  String get name => runtimeType.toString();
}
