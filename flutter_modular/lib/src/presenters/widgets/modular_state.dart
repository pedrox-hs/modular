import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

import '../../../flutter_modular.dart';
import '../modular_base.dart';

abstract class ModularState<TWidget extends StatefulWidget,
    TBind extends Object> extends State<TWidget> {
  late final TBind _scope = inject();

  TBind get store => _scope;
  TBind get bloc => _scope;
  TBind get cubit => _scope;
  TBind get controller => _scope;

  @override
  void dispose() {
    super.dispose();
    if (Modular.isSingleton(_scope)) return;
    final isDisposed = Modular.dispose<TBind>();
    if (isDisposed) {
      return;
    }

    if (_scope is Disposable) {
      (_scope as Disposable).dispose();
    }

    if (_scope is Sink) {
      (_scope as Sink).close();
    } else if (_scope is ChangeNotifier) {
      (_scope as ChangeNotifier).dispose();
    } else if (_scope is Store) {
      (_scope as Store).destroy();
    }
  }
}
