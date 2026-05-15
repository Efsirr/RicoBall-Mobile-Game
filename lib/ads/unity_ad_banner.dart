import 'package:flutter/widgets.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'unity_ads_service.dart';

class UnityAdBanner extends StatelessWidget {
  const UnityAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UnityAdsService.instance,
      builder: (context, _) {
        if (!UnityAdsService.instance.isInitialized) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: BannerSize.standard.height.toDouble(),
          child: Center(
            child: UnityBannerAd(
              placementId: UnityAdConfig.bannerPlacementId,
              onFailed: (placementId, error, message) {
                debugPrint(
                  'Unity banner failed for $placementId: $error $message',
                );
              },
            ),
          ),
        );
      },
    );
  }
}
