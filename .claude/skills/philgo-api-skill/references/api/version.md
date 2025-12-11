# 필고 버전 API



## version

호출:
`GET https://philgo.com/func.php?func=version`


응답:
```json
{"version":"2025-12-11-14-41-07","app":{"android":{"version":"2.0.3","build_number":36},"ios":{"version":"2.0.3","build_number":36}}}
```

- `version`: 홈페이지의 서버 버전 (홈페이지가 빌드된 날짜 및 시간)
- `app.android.version`: Android 앱 버전
- `app.android.build_number`: Android 앱 빌드 번호
- `app.ios.version`: iOS 앱 버전
- `app.ios.build_number`: iOS 앱 빌드 번호

