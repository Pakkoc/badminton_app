import 'dart:typed_data';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(supabaseProvider));
});

/// 스토리지 리포지토리.
///
/// Supabase Storage에 이미지를 업로드/삭제한다.
/// 버킷: profile-images, post-images, inventory-images
/// 파일 경로 규칙: {userId}/{uuid}.jpg
class StorageRepository {
  final SupabaseClient client;

  StorageRepository(this.client);

  /// 이미지를 업로드하고 public URL을 반환한다.
  ///
  /// [bucket] 버킷 이름 (profile-images, post-images, inventory-images).
  /// [file] 업로드할 파일 데이터 (Uint8List).
  /// [path] 파일 경로 ({userId}/{uuid}.jpg).
  Future<String> uploadImage(
    String bucket,
    dynamic file,
    String path,
  ) async {
    try {
      await client.storage.from(bucket).uploadBinary(
            path,
            file as Uint8List,
          );
      final publicUrl =
          client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 이미지를 삭제한다.
  ///
  /// [bucket] 버킷 이름.
  /// [path] 파일 경로.
  Future<void> deleteImage(String bucket, String path) async {
    try {
      await client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
