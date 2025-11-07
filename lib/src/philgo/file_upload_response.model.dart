class FileUploadResponse {
  final String url;
  final String? qr_code;
  final bool? deleted;

  FileUploadResponse({required this.url, this.qr_code, this.deleted});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      url: json['url'],
      qr_code: json['qr_code'],
      deleted: json['deleted'],
    );
  }

  @override
  String toString() {
    // 파일 업로드 응답 정보를 문자열로 반환
    // url은 필수, qr_code와 deleted는 선택사항
    final parts = <String>['url: $url'];

    if (qr_code != null && qr_code!.isNotEmpty) {
      parts.add('qr_code: $qr_code');
    }

    if (deleted != null) {
      parts.add('deleted: $deleted');
    }

    return 'FileUploadResponse(${parts.join(', ')})';
  }
}
