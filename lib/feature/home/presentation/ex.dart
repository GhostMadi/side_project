import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeatureChannel {
  static const _base = 'com.app.feature';

  final MethodChannel _method;
  final EventChannel _events;

  FeatureChannel._(int viewId)
    : _method = MethodChannel('$_base/view_$viewId'),
      _events = EventChannel('$_base/view_${viewId}_events');

  static FeatureChannel attachToView(int viewId) => FeatureChannel._(viewId);

  // --- Calls ---
  Future<void> init({Map<String, dynamic>? options}) =>
      _method.invokeMethod('init', options ?? {});

  Future<void> dispose() => _method.invokeMethod('dispose');

  Future<void> setData(Map<String, dynamic> data) =>
      _method.invokeMethod('setData', data);

  Future<void> doAction(String action, [Map<String, dynamic>? args]) =>
      _method.invokeMethod('doAction', {'action': action, 'args': args ?? {}});

  // --- Events ---
  Stream<Map<String, dynamic>> get stream =>
      _events.receiveBroadcastStream().map((e) => Map<String, dynamic>.from(e));
}

class NativeFeatureView extends StatefulWidget {
  const NativeFeatureView({super.key, this.onCreated});
  final void Function(int viewId)? onCreated;

  @override
  State<NativeFeatureView> createState() => _NativeFeatureViewState();
}

class _NativeFeatureViewState extends State<NativeFeatureView> {
  @override
  Widget build(BuildContext context) {
    const viewType = 'com.app.feature/view';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        creationParams: const {},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: widget.onCreated,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: const {},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: widget.onCreated,
      );
    }

    return const SizedBox.shrink();
  }
}
