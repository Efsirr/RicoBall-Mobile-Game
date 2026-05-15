import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdConfig {
  static const bool testMode = bool.fromEnvironment(
    'UNITY_ADS_TEST_MODE',
    defaultValue: true,
  );

  static const String androidGameId = String.fromEnvironment(
    'UNITY_ADS_ANDROID_GAME_ID',
  );
  static const String iosGameId = String.fromEnvironment(
    'UNITY_ADS_IOS_GAME_ID',
  );
  static const String bannerPlacementId = String.fromEnvironment(
    'UNITY_ADS_BANNER_PLACEMENT_ID',
    defaultValue: 'banner',
  );
  static const String interstitialPlacementId = String.fromEnvironment(
    'UNITY_ADS_INTERSTITIAL_PLACEMENT_ID',
    defaultValue: 'video',
  );
  static const String rewardedPlacementId = String.fromEnvironment(
    'UNITY_ADS_REWARDED_PLACEMENT_ID',
    defaultValue: 'rewardedVideo',
  );

  static String get gameId {
    if (kIsWeb) return '';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidGameId,
      TargetPlatform.iOS => iosGameId,
      _ => '',
    };
  }

  static bool get isSupported => gameId.isNotEmpty;
}

class UnityAdsService extends ChangeNotifier {
  static final UnityAdsService instance = UnityAdsService._();

  final Map<String, bool> _loadedPlacements = {
    UnityAdConfig.interstitialPlacementId: false,
    UnityAdConfig.rewardedPlacementId: false,
  };
  final Set<String> _loadingPlacements = {};

  bool _initialized = false;
  bool _initializing = false;
  bool _showingAd = false;

  UnityAdsService._();

  bool get isEnabled => UnityAdConfig.isSupported;

  bool get isInitialized => _initialized;

  bool get isRewardedReady =>
      _initialized &&
      (_loadedPlacements[UnityAdConfig.rewardedPlacementId] ?? false);

  Future<void> initialize() async {
    if (!isEnabled || _initialized || _initializing) return;

    _initializing = true;
    notifyListeners();

    try {
      await UnityAds.init(
        gameId: UnityAdConfig.gameId,
        testMode: UnityAdConfig.testMode,
        onComplete: () {
          _initialized = true;
          _initializing = false;
          notifyListeners();
          _loadVideoPlacements();
        },
        onFailed: (error, message) {
          debugPrint('Unity Ads initialization failed: $error $message');
          _initializing = false;
          notifyListeners();
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Unity Ads initialization threw: $error');
      debugPrintStack(stackTrace: stackTrace);
      _initializing = false;
      notifyListeners();
    }
  }

  Future<bool> showInterstitial({VoidCallback? onFinished}) {
    return _showVideoAd(
      placementId: UnityAdConfig.interstitialPlacementId,
      onFinished: onFinished,
    );
  }

  Future<bool> showRewarded({required VoidCallback onReward}) {
    return _showVideoAd(
      placementId: UnityAdConfig.rewardedPlacementId,
      onComplete: onReward,
    );
  }

  void _loadVideoPlacements() {
    for (final placementId in _loadedPlacements.keys) {
      _loadPlacement(placementId);
    }
  }

  void _loadPlacement(String placementId) {
    if (!_initialized ||
        _loadedPlacements[placementId] == true ||
        _loadingPlacements.contains(placementId)) {
      return;
    }

    _loadingPlacements.add(placementId);
    UnityAds.load(
      placementId: placementId,
      onComplete: (placementId) {
        _loadingPlacements.remove(placementId);
        _loadedPlacements[placementId] = true;
        notifyListeners();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity Ads load failed for $placementId: $error $message');
        _loadingPlacements.remove(placementId);
        _loadedPlacements[placementId] = false;
        notifyListeners();
      },
    );
  }

  Future<bool> _showVideoAd({
    required String placementId,
    VoidCallback? onComplete,
    VoidCallback? onFinished,
  }) async {
    if (!_initialized || _showingAd) return false;

    final isLoaded = _loadedPlacements[placementId] ?? false;
    if (!isLoaded) {
      _loadPlacement(placementId);
      return false;
    }

    _showingAd = true;
    _loadedPlacements[placementId] = false;
    notifyListeners();

    try {
      await UnityAds.showVideoAd(
        placementId: placementId,
        onComplete: (_) {
          onComplete?.call();
          _finishAd(placementId, onFinished: onFinished);
        },
        onSkipped: (_) => _finishAd(placementId, onFinished: onFinished),
        onFailed: (_, error, message) {
          debugPrint('Unity Ads show failed for $placementId: $error $message');
          _finishAd(placementId, onFinished: onFinished);
        },
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('Unity Ads show threw for $placementId: $error');
      debugPrintStack(stackTrace: stackTrace);
      _finishAd(placementId, onFinished: onFinished);
      return false;
    }
  }

  void _finishAd(String placementId, {VoidCallback? onFinished}) {
    _showingAd = false;
    onFinished?.call();
    notifyListeners();
    _loadPlacement(placementId);
  }
}
