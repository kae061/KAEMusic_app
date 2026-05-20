import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'username': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'displayName': username,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateDisplayName(String displayName) async {
    final response = await _dio.put(
      ApiEndpoints.updateDisplayName,
      data: {'displayName': displayName},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateAvatar(String avatarUrl) async {
    final response = await _dio.put(
      ApiEndpoints.updateAvatar,
      data: {'avatarUrl': avatarUrl},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> uploadAvatarFile(String filePath, String fileName) async {
    // Read file as bytes to support both web (dart:html) and mobile (dart:io)
    final file = XFile(filePath);
    final bytes = await file.readAsBytes();
    
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      ApiEndpoints.updateAvatar,
      data: formData,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> deleteAvatar() async {
    final response = await _dio.delete(ApiEndpoints.updateAvatar);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}