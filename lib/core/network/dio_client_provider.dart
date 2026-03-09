import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'doh_service.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Install the DNS-over-HTTPS interceptor globally so all services
  // bypass censorship and apply user DNS preferences.
  dio.interceptors.add(DohInterceptor());

  return dio;
});
