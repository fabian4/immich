import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/shared/services/api.service.dart';
import 'package:openapi/api.dart';

class AuthGuard extends AutoRouteGuard {
  final ApiService _apiService;
  AuthGuard(this._apiService);
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      var res = await _apiService.authenticationApi.validateAccessToken();

      if (res != null && res.authStatus) {
        resolver.next(true);
      } else {
        router.replaceAll([const LoginRoute()]);
      }
    } on ApiException catch (e) {
      if (e.code == HttpStatus.badRequest &&
          e.innerException is SocketException) {
        // offline?
        resolver.next(true);
      } else {
        debugPrint("Error [onNavigation] ${e.toString()}");
        router.replaceAll([const LoginRoute()]);
      }
      return;
    }
  }
}
