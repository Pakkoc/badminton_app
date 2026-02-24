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
/// 파일 경로 규칙: {userId}/{uuid}.jpg
///
/// ## 필요한 Supabase Storage 버킷 (Dashboard에서 수동 생성)
///
/// | 버킷 이름          | 공개 여부 | 용도                     |
/// |-------------------|----------|--------------------------|
/// | profile-images    | public   | 사용자 프로필 이미지        |
/// | post-images       | public   | 소식/공지 게시글 이미지      |
/// | inventory-images  | public   | 재고 아이템 이미지          |
///
/// ### 버킷 설정
/// - 허용 MIME: image/jpeg, image/png, image/webp
/// - 최대 파일 크기: 5MB
/// - RLS 정책: 인증된 사용자만 업로드/삭제 가능,
///   공개 읽기 허용
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
