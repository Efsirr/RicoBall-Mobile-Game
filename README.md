# ricochet_core

A new Flutter project.

## Unity Ads

Unity Ads is wired through `unity_ads_plugin` and is disabled until a platform
Game ID is provided at build/run time.

Example Android run:

```sh
flutter run \
  --dart-define=UNITY_ADS_ANDROID_GAME_ID=your_android_game_id \
  --dart-define=UNITY_ADS_BANNER_PLACEMENT_ID=banner \
  --dart-define=UNITY_ADS_INTERSTITIAL_PLACEMENT_ID=video \
  --dart-define=UNITY_ADS_REWARDED_PLACEMENT_ID=rewardedVideo
```

For iOS, use `UNITY_ADS_IOS_GAME_ID`. Ads run in Unity test mode by default;
set `--dart-define=UNITY_ADS_TEST_MODE=false` for production builds after the
Unity Dashboard placements are ready.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
