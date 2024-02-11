import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  var parse = ModularRouteInformationParser();

  BuildContext context = Container().createElement();

  group('Single Module | ', () {
    test('should retrive route /', () async {
      final route = await parse.selectRoute('/', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<Container>());
      expect(route.path, '/');
    });

    test('should retrive route /list', () async {
      final route = await parse.selectRoute('/list', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/list');
    });
    test('should retrive dynamic route /list/:id', () async {
      final route = await parse.selectRoute('/list/2', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '2');
      expect(route.path, '/list/2');
    });

    test('should retrieve route /list?id=1234&type=DYN', () async {
      final route = await parse.selectRoute('/list?id=1234&type=DYN', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/list?id=1234&type=DYN');
      expect(route.uri?.path, '/list');
      expect(route.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.fragment, '');
      expect(route.args.uri?.path, '/list');
      expect(route.args.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.args.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.args.fragment, '');
    });

    test('should retrieve route /list?id=1234&type=DYN#abcd', () async {
      final route = await parse.selectRoute('/list?id=1234&type=DYN#abcd', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/list?id=1234&type=DYN#abcd');
      expect(route.uri?.path, '/list');
      expect(route.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.fragment, 'abcd');
      expect(route.args.uri?.path, '/list');
      expect(route.args.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.args.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.args.fragment, 'abcd');
    });

    test('should retrieve route /mock/list#abcd', () async {
      final route = await parse.selectRoute('/list#abcd', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/list#abcd');
      expect(route.uri?.path, '/list');
      expect(route.queryParams, {});
      expect(route.fragment, 'abcd');
      expect(route.args.uri?.path, '/list');
      expect(route.args.queryParams, {});
      expect(route.args.fragment, 'abcd');
    });

    test('should retrieve Wildcard route when not exist path', () async {
      final route = await parse.selectRoute('/paulo', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<FlutterLogo>());
    });

    test('should retrieve Wildcard route when path with query params doesn\'t exist', () async {
      final route = await parse.selectRoute('/paulo?adbc=1234', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<FlutterLogo>());
    });

    test('should retrieve Wildcard route when path with fragment doesn\'t exist', () async {
      final route = await parse.selectRoute('/paulo#adbc=1234', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<FlutterLogo>());
    });

    test('should guard route /401', () async {
      expect(parse.selectRoute('/401', module: ModuleMock()), throwsA(isA<ModularError>()));
    });
  });

  group('Multi Module | ', () {
    test('should retrieve route /mock', () async {
      final route = await parse.selectRoute('/mock', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<SizedBox>());
      expect(route.path, '/mock/');
    });

    test('should retrieve route /mock/', () async {
      final route = await parse.selectRoute('/mock/', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<SizedBox>());
      expect(route.path, '/mock/');
    });

    test('should retrieve route /mock/list', () async {
      final route = await parse.selectRoute('/mock/list', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/mock/list');
    });

    test('should retrieve route /mock/list?id=1234&type=DYN', () async {
      final route = await parse.selectRoute('/mock/list?id=1234&type=DYN', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/mock/list?id=1234&type=DYN');
      expect(route.uri?.path, '/mock/list');
      expect(route.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.fragment, '');
      expect(route.args.uri?.path, '/mock/list');
      expect(route.args.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.args.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.args.fragment, '');
    });

    test('should retrieve route /mock/list?id=1234&type=DYN', () async {
      final route = await parse.selectRoute('/mock/list?id=1234&type=DYN', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/mock/list?id=1234&type=DYN');
      expect(route.uri?.path, '/mock/list');
      expect(route.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.fragment, '');
      expect(route.args.uri?.path, '/mock/list');
      expect(route.args.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.args.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
      expect(route.args.fragment, '');
    });

    test('should retrieve route /mock?id=1234&type=DYN#abcd', () async {
      final route = await parse.selectRoute('/mock?id=1234&type=DYN#abcd', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<SizedBox>());
      expect(route.uri?.path, '/mock/');
      expect(route.path, '/mock/?id=1234&type=DYN#abcd');
      expect(route.args.queryParams, {'id': '1234', 'type': 'DYN'});
      expect(route.args.queryParamsAll, {
        'id': ['1234'],
        'type': ['DYN']
      });
    });

    test('should retrieve route /mock/list#abcd', () async {
      final route = await parse.selectRoute('/mock/list#abcd', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<ListView>());
      expect(route.path, '/mock/list#abcd');
      expect(route.uri?.path, '/mock/list');
      expect(route.queryParams, {});
      expect(route.fragment, 'abcd');
      expect(route.args.uri?.path, '/mock/list');
      expect(route.args.queryParams, {});
      expect(route.args.fragment, 'abcd');
    });

    test('should retrieve dynamic route /mock/list/:id', () async {
      final route = await parse.selectRoute('/mock/list/3', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '3');
      expect(route.path, '/mock/list/3');
    });

    test('should retrieve Wildcard route when not exist path', () async {
      final route = await parse.selectRoute('/mock/paulo', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<FlutterLogo>());
    });

    test('should guard route /mock/listguarded', () async {
      expect(parse.selectRoute('/mock/listguarded', module: ModuleMock()), throwsA(isA<ModularError>()));
    });

    test('should guard route /mock/listguarded with params', () async {
      expect(parse.selectRoute('/mock/listguarded?abc=def', module: ModuleMock()), throwsA(isA<ModularError>()));
    });

    test('should guard route /mock/listguarded with fragment', () async {
      expect(parse.selectRoute('/mock/listguarded#abc=def', module: ModuleMock()), throwsA(isA<ModularError>()));
    });

    test('should guard route /guarded/list', () async {
      expect(parse.selectRoute('/guarded/list', module: ModuleMock()), throwsA(isA<ModularError>()));
    });
  });

  group('Outlet Module | ', () {
    test('should retrieve route /home/tab1', () async {
      final route = await parse.selectRoute('/home/tab1', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<Scaffold>());
      expect(route.path, '/home');
      expect(route.routerOutlet.length, 1);
      expect(route.routerOutlet[0].child!(context, ModularArguments()), isA<TextField>());
      expect(route.routerOutlet[0].path, '/home/tab1');
    });
    test('should retrieve route /home/tab2/:id', () async {
      final route = await parse.selectRoute('/home/tab2/3', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<Scaffold>());
      expect(route.path, '/home');
      expect(route.routerOutlet.length, 1);
      expect(route.routerOutlet[0].child!(context, route.routerOutlet[0].args).toString(), '3');
      expect(route.routerOutlet[0].path, '/home/tab2/3');
    });
    test('should throw error if not exist route /home/tab3', () async {
      expect(parse.selectRoute('/home/tab3', module: ModuleMock()), throwsA(isA<ModularError>()));
    });

    test('should retrieve route  (Module)', () async {
      final route = await parse.selectRoute('/mock/home', module: ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, ModularArguments()), isA<SizedBox>());
      expect(route.path, '/mock/');
      expect(route.modulePath, '/mock');
      expect(route.routerOutlet.length, 1);
      expect(route.routerOutlet[0].child!(context, ModularArguments()), isA<Container>());
      expect(route.routerOutlet[0].path, '/mock/home');
    });
  });
}

class ModuleMock extends Module {
  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, isLazy: false),
    Bind((i) => StreamController(), isLazy: false),
    Bind((i) => ValueNotifier(0), isLazy: false),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (context, args) => Container(),
    ),
    ChildRoute(
      '/home',
      child: (context, args) => Scaffold(),
      children: [
        ChildRoute('/tab1', child: (context, args) => TextField()),
        ChildRoute(
          '/tab2/:id',
          child: (context, args) => CustomWidget(
            text: args.params['id'],
          ),
        ),
      ],
    ),
    ModuleRoute('/mock', module: ModuleMock2()),
    ModuleRoute('/guarded', guards: [MyGuardModule()], module: ModuleGuarded()),
    ChildRoute('/list', child: (context, args) => ListView()),
    ChildRoute(
      '/401',
      guards: [MyGuard()],
      child: (context, args) => SingleChildScrollView(),
    ),
    ChildRoute(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args.params['id'],
      ),
    ),
    ChildRoute('**', child: (context, args) => FlutterLogo())
  ];
}

class ModuleMock2 extends Module {
  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, isLazy: false),
    Bind((i) => StreamController(), isLazy: false),
    Bind((i) => ValueNotifier(0), isLazy: false),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (context, args) => SizedBox(), children: [
      ChildRoute('/home', child: (context, args) => Container()),
    ]),
    ChildRoute(
      '/list',
      child: (context, args) => ListView(),
    ),
    ChildRoute(
      '/listguarded',
      guards: [MyGuard()],
      child: (context, args) => ListView(),
    ),
    ChildRoute(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args.params['id'],
      ),
    ),
    ChildRoute('**', child: (context, args) => FlutterLogo())
  ];
}

class ModuleGuarded extends Module {
  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, isLazy: false),
    Bind((i) => StreamController(), isLazy: false),
    Bind((i) => ValueNotifier(0), isLazy: false),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (context, args) => SizedBox(), children: [
      ChildRoute('/home', child: (context, args) => Container()),
      ChildRoute('/guarded', child: (context, args) => Container()),
    ]),
    ChildRoute(
      '/list',
      child: (context, args) => ListView(),
    ),
    ChildRoute(
      '/listguarded',
      guards: [MyGuard()],
      child: (context, args) => ListView(),
    ),
    ChildRoute(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args.params['id'],
      ),
    ),
    ChildRoute('**', child: (context, args) => FlutterLogo())
  ];
}

class CustomWidget extends StatelessWidget {
  final String text;

  const CustomWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return text;
  }
}

class MyGuard extends RouteGuard {
  MyGuard({String? guardedRoute}) : super(guardedRoute);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    if (path == '/401') {
      return false;
    } else if (path.startsWith('/mock/listguarded')) {
      return false;
    } else {
      return true;
    }
  }
}

class MyGuardModule extends RouteGuard {
  MyGuardModule({String? guardedRoute}) : super(guardedRoute);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    if (path == '/guarded/list') {
      return false;
    } else {
      return true;
    }
  }
}
