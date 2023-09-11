import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class _HtmlElementViewController extends PlatformViewController
    with WidgetsBindingObserver {
  _HtmlElementViewController(
      this.viewId,
      this.viewType,
      );

  @override
  final int viewId;

  /// The unique identifier for the HTML view type to be embedded by this widget.
  ///
  /// A PlatformViewFactory for this type must have been registered.
  final String viewType;

  bool _initialized = false;

  Future<void> _initialize() async {
    final args = <String, dynamic>{
      'id': viewId,
      'viewType': viewType,
    };
    await SystemChannels.platform_views.invokeMethod<void>('create', args);
    _initialized = true;
  }

  @override
  Future<void> clearFocus() async {
    // Currently this does nothing on Flutter Web.
    // TODO(het): Implement this. See https://github.com/flutter/flutter/issues/39496
  }

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    // We do not dispatch pointer events to HTML views because they may contain
    // cross-origin iframes, which only accept user-generated events.
  }

  @override
  Future<void> dispose() async {
    if (_initialized) {
      await SystemChannels.platform_views.invokeMethod<void>('dispose', viewId);
    }
  }
}

mixin RtcRenderMixin<T extends StatefulWidget> on State<T> {
  @protected
  Widget buildPlatformView({
    PlatformViewCreatedCallback? onPlatformViewCreated,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: PlatformViewLink(
        viewType: 'AgoraSurfaceView',
        onCreatePlatformView: _onCreatePlatformView(
            onPlatformViewCreated
        ),
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return PlatformViewSurface(
            controller: controller,
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          );
        },
      ),
    );
  }

  CreatePlatformViewCallback _onCreatePlatformView(
      PlatformViewCreatedCallback? onPlatformViewCreated) {
    return (PlatformViewCreationParams params) {
      final controller = _HtmlElementViewController(params.id, params.viewType);
      controller._initialize().then((_) {
        params.onPlatformViewCreated(params.id);
        _onPlatformViewCreated(onPlatformViewCreated)(params.id);
      });
      return controller;
    };
  }

  PlatformViewCreatedCallback _onPlatformViewCreated(PlatformViewCreatedCallback? onPlatformViewCreated) {
    return (int id) {
      onPlatformViewCreated?.call(id);
    };
  }
}