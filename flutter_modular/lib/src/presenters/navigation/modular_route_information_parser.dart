import 'package:flutter/material.dart';

import '../../../flutter_modular.dart';

bool _firstParse = false;

class ModularRouteInformationParser extends RouteInformationParser<ModularRoute> {
  final Map<String, Module> injectMap;

  ModularRouteInformationParser({this.injectMap = const {}});

  @visibleForTesting
  static void reset() {
    _firstParse = false;
  }

  @override
  Future<ModularRoute> parseRouteInformation(RouteInformation routeInformation) async {
    late final String path;
    if (!_firstParse) {
      if (routeInformation.location == null || routeInformation.location == '/') {
        // ignore: invalid_use_of_visible_for_testing_member
        path = initialRouteDeclaratedInMaterialApp;
      } else {
        path = routeInformation.location!;
      }

      _firstParse = true;
    } else {
      // ignore: invalid_use_of_visible_for_testing_member
      path = routeInformation.location ?? initialRouteDeclaratedInMaterialApp;
    }

    final route = await selectRoute(path);
    return route;
  }

  @override
  RouteInformation restoreRouteInformation(ModularRoute router) {
    return RouteInformation(
      location: (_getRoute(router)?.path ?? '/').split('@').last,
    );
  }

  ModularRoute? _getRoute(ModularRoute? currentConfiguration) {
    if (currentConfiguration == null) return null;
    var candidate = currentConfiguration;
    var isRunning = true;

    while (isRunning) {
      if (candidate.routerOutlet.isNotEmpty == true) {
        candidate = candidate.routerOutlet.last;
      } else {
        isRunning = false;
      }
    }

    return candidate;
  }

  ModularRoute? _searchInModule(Module module, String routerName, Uri uri, String? pushStyle) {
    uri = uri.normalizePath();
    final routers = module.routes.map((e) {
      if (e is ChildRoute || e is WildcardRoute) {
        return e.copyWith(currentModule: module);
      } else {
        return e.copyWith(currentModule: e.module);
      }
    }).toList();
    routers.sort((preview, actual) {
      return preview.routerName.contains('/:') ? 1 : 0;
    });
    for (var route in routers) {
      var r = _searchRoute(route, routerName, uri, pushStyle);
      if (r != null) {
        return r;
      }
    }
    return null;
  }

  ModularRoute? _normalizeRoute(ModularRoute route, String routerName, Uri uri, String? pushStyle) {
    ModularRoute? router;
    if (routerName == uri.path || routerName == "${uri.path}/") {
      //router = route.module!.routes[0];
      final routes = route.module!.routes;
      router = routes.firstWhere((element) => element.routerName == '/', orElse: () => routes[0]);
      if (router.module != null) {
        var _routerName = (routerName + route.routerName).replaceFirst('//', '/');
        router = _searchInModule(route.module!, _routerName, uri, pushStyle);
      } else {
        router = router.copyWith(uri: uri.replace(path: routerName));
      }
    } else {
      router = _searchInModule(route.module!, routerName, uri, pushStyle);
    }
    return router;
  }

  ModularRoute? _searchRoute(ModularRoute route, String routerName, Uri uri, String? pushStyle) {
    final tempRouteName = (routerName + route.routerName).replaceFirst('//', '/');
    if (route.child == null) {
      var _routerName = ('$routerName${route.routerName}/').replaceFirst('//', '/');
      var router = _normalizeRoute(route, _routerName, uri, pushStyle);

      if (router != null) {
        router = router.copyWith(
          modulePath: router.modulePath == null ? '/' : tempRouteName,
          currentModule: router.currentModule ?? route.currentModule,
          guards: [if (route.guards != null) ...route.guards!, if (router.guards != null) ...router.guards!],
        );

        if (router.transition == TransitionType.defaultTransition) {
          router = router.copyWith(
            transition: route.transition,
            customTransition: route.customTransition,
          );
        }
        if (route.module != null) {
          Modular.bindModule(route.module!, path: pushStyle == null ? uri.path : '${uri.path}@$pushStyle');
        }
        return router;
      }
    } else {
      if (route.children.isNotEmpty) {
        for (var routeChild in route.children) {
          var r = _searchRoute(routeChild, tempRouteName, uri, pushStyle);
          if (r != null) {
            // r.currentModule?.paths.remove(uri.toString());
            r = r.copyWith(modulePath: tempRouteName);
            route = route.copyWith(args: r.args, routerOutlet: [r], uri: uri.replace(path: tempRouteName));
            return route;
          }
        }
      }

      if (Uri.parse(tempRouteName).pathSegments.length != uri.pathSegments.length) {
        return null;
      }
      var parseRoute = _parseUrlParams(route, tempRouteName, uri);

      if (uri.path != parseRoute.uri?.path) {
        return null;
      }

      if (parseRoute.currentModule != null) {
        Modular.bindModule(parseRoute.currentModule!, path: pushStyle == null ? uri.path : '${uri.path}@$pushStyle');
      }
      return parseRoute;
    }

    return null;
  }

  String resolveOutletModulePath(String tempRouteName, String outletModulePath) {
    var temp = '$tempRouteName/$outletModulePath'.replaceAll('//', '/');
    if (temp.characters.last == '/') {
      return temp.substring(0, temp.length - 1);
    } else {
      return temp;
    }
  }

  String prepareToRegex(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      var url = part.contains(":") ? "(.*?)" : part;
      newUrl.add(url);
    }

    return newUrl.join("/");
  }

  ModularRoute _parseUrlParams(ModularRoute router, String routeNamed, Uri uri) {
    if (routeNamed.contains('/:')) {
      final regExp = RegExp(
        "^${prepareToRegex(routeNamed)}\$",
        caseSensitive: true,
      );
      var r = regExp.firstMatch(uri.path);
      if (r != null) {
        var params = <String, String>{};
        var paramPos = 0;
        final routeParts = routeNamed.split('/');
        final pathParts = uri.path.split('/');

        //  print('Match! Processing $path as $routeNamed');

        for (var routePart in routeParts) {
          if (routePart.contains(":")) {
            var paramName = routePart.replaceFirst(':', '');
            if (pathParts[paramPos].isNotEmpty) {
              params[paramName] = pathParts[paramPos];
              routeNamed = routeNamed.replaceFirst(routePart, params[paramName]!);
            }
          }
          paramPos++;
        }
        uri = uri.replace(path: routeNamed);
        return router.copyWith(args: router.args.copyWith(params: params, uri: uri), uri: uri);
      }

      uri = uri.replace(path: routeNamed);
      return router.copyWith(args: router.args.copyWith(params: null, uri: uri), uri: uri);
    }

    uri = uri.replace(path: routeNamed);
    return router.copyWith(uri: uri, args: router.args.copyWith(uri: uri));
  }

  ModularRoute? _searchWildcard(
    String path,
    Module module,
    String? pushStyle,
  ) {
    ModularRoute? found;

    var pathSegments = path.split('/')..removeLast();
    final length = pathSegments.length;
    for (var i = 0; i < length; i++) {
      final localPath = pathSegments.join('/');
      final route = _searchInModule(module, "", Uri.parse(localPath.isEmpty ? '/' : localPath), pushStyle);

      if (route != null) {
        if (route.children.isEmpty) {
          final lastRoute = route.currentModule?.routes.last;
          found = lastRoute?.routerName == '**' ? lastRoute : null;
        } else {
          found = route.children.last.routerName == '**' ? route.children.last : null;
          if (route.routerName != '/') {
            break;
          }
        }
      }

      if (found != null) {
        break;
      }
      pathSegments.removeLast();
    }

    return found?.routerName == '**' ? found : null;
  }

  Future<ModularRoute> selectRoute(String path, {Module? module, dynamic arguments, String? pushStyle}) async {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    var uri = Uri.parse(path);

    final allModules = <Module>[
      if (module != null) module,
      Modular.initialModule,
      ...injectMap.values,
    ];

    var router = allModules.fold<ModularRoute?>(
      null,
      (previous, current) {
        var route = previous ?? _searchInModule(current, "", uri, pushStyle);
        if (route is RedirectRoute) {
          uri = Uri.parse(route.to);
          route = _searchInModule(current, "", uri, pushStyle);
        }
        return route ?? _searchWildcard(uri.path, current, pushStyle);
      },
    );

    if (router == null) {
      throw ModularError('Route \'${uri.path}\' not found');
    }

    router = router.copyWith(
      args: router.args.copyWith(uri: router.uri, data: arguments),
    );
    if (pushStyle != null) {
      if (router.routerOutlet.isEmpty) {
        router = router.copyWith(uri: Uri.parse('${uri.path}@$pushStyle'));
      } else {
        var miniRoute = router.routerOutlet.last;
        miniRoute = miniRoute.copyWith(
          uri: Uri.parse('${miniRoute.path}@$pushStyle'),
        );
        router = router.copyWith(routerOutlet: [miniRoute]);
      }
    }
    return canActivate(router.path!, router);
  }

  Future<ModularRoute> canActivate(String path, ModularRoute router) async {
    if (router.guards?.isNotEmpty == true) {
      router = await _checkGuard(path, router);
    } else if (router.routerOutlet.isNotEmpty) {
      for (final r in router.routerOutlet) {
        await _checkGuard(path, r, true);
      }
    }

    return router;
  }

  Future<ModularRoute> _checkGuard(String path, ModularRoute router, [bool isRouterOutlet = false]) async {
    for (var guard in router.guards ?? []) {
      try {
        final result = await guard.canActivate(path, router);
        if (!result && guard.guardedRoute != null && !isRouterOutlet) {
          print(ModularError('$path is CAN\'T ACTIVATE'));
          print('redirect to \'${guard.guardedRoute}\'');
          return await selectRoute(guard.guardedRoute!);
        }
      } on ModularError {
        rethrow;
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        throw ModularError('RouteGuard error. Check ($path) in ${router.currentModule.runtimeType}');
      }
    }
    return router;
  }
}
