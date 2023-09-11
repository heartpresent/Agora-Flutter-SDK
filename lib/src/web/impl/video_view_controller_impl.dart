import 'package:agora_rtc_engine/src/web/render/video_view_controller.dart';
import 'package:agora_rtc_engine/src/web/classes.dart';
import 'package:agora_rtc_engine/src/web/impl/rtc_engine_impl.dart';
import 'package:agora_rtc_engine/src/web/rtc_engine.dart';
import 'package:agora_rtc_engine/src/web/enums.dart';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

const int kTextureNotInit = -1;

extension VideoViewControllerBaseExt on VideoViewControllerBase {
  bool isSame(VideoViewControllerBase other) {
    bool isSame = canvas.view == other.canvas.view &&
        canvas.renderMode == other.canvas.renderMode &&
        canvas.mirrorMode == other.canvas.mirrorMode &&
        canvas.uid == other.canvas.uid &&
        canvas.sourceType == other.canvas.sourceType &&
        canvas.cropArea == other.canvas.cropArea &&
        canvas.setupMode == other.canvas.setupMode &&
        canvas.mediaPlayerId == other.canvas.mediaPlayerId;
    isSame = isSame &&
        connection?.channelId == other.connection?.channelId &&
        connection?.localUid == other.connection?.localUid;
    isSame = isSame && shouldUseFlutterTexture == other.shouldUseFlutterTexture;
    isSame = isSame && useAndroidSurfaceView == other.useAndroidSurfaceView;
    return isSame;
  }

  @internal
  bool get shouldUseFlutterTexture =>
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows) ||
          useFlutterTexture;

  @internal
  bool get shouldHandlerRenderMode =>
      this is VideoViewControllerBaseMixin &&
          (this as VideoViewControllerBaseMixin).shouldHandlerRenderMode;

  @internal
  bool get isLocalUid => canvas.uid == 0;
}
mixin VideoViewControllerBaseMixin implements VideoViewControllerBase {
  int _textureId = kTextureNotInit;

  bool _isCreatedRender = false;
  bool _isDisposeRender = false;

  @internal
  bool get isInitialized => (rtcEngine as RtcEngineImpl).isInitialized;

  @internal
  void addInitializedCompletedListener(VoidCallback listener) {
    final engine = rtcEngine as RtcEngineImpl;
    engine.addInitializedCompletedListener(listener);
  }

  @internal
  void removeInitializedCompletedListener(VoidCallback listener) {
    final engine = rtcEngine as RtcEngineImpl;
    engine.removeInitializedCompletedListener(listener);
  }

  @override
  int getTextureId() => _textureId;

  @override
  void setTextureId(int textureId) {
    _textureId = textureId;
  }

  @override
  Future<void> dispose() async {
    _isDisposeRender = true;
    _isCreatedRender = false;
  }

  @protected
  Future<void> disposeRenderInternal() async {
    // if (shouldUseFlutterTexture) {
    //   await rtcEngine.globalVideoViewController
    //       .destroyTextureRender(getTextureId());
    //   _textureId = kTextureNotInit;
    //   return;
    // }

    VideoCanvas videoCanvas = VideoCanvas(
      view: 0, // null
      renderMode: canvas.renderMode,
      mirrorMode: canvas.mirrorMode,
      uid: canvas.uid,
      sourceType: canvas.sourceType,
      cropArea: canvas.cropArea,
      setupMode: canvas.setupMode,
      mediaPlayerId: canvas.mediaPlayerId,
    );
    try {
      if (canvas.uid != 0) {
        await rtcEngine.setupRemoteVideo(videoCanvas);
      } else {
        await rtcEngine.setupLocalVideo(videoCanvas);
      }
    } catch (e) {
      debugPrint('disposeRenderInternal error: ${e.toString()}');
    }
  }

  @internal
  @override
  Future<void> disposeRender() async {
    if (!_isCreatedRender || _isDisposeRender) {
      return;
    }
    _isDisposeRender = true;
    _isCreatedRender = false;

    await disposeRenderInternal();
  }

  @override
  Future<void> initializeRender() async {

    if (shouldUseFlutterTexture) {
      if (_textureId == kTextureNotInit) {
        _textureId = await createTextureRender(
          canvas.uid!,
          connection?.channelId ?? '',
          canvas.sourceType?.index ?? getVideoSourceType(),
          canvas.setupMode?.index ??
              VideoViewSetupMode.videoViewSetupReplace.index,
        );
      }
    } else {
      // do nothing if platform view rendering
    }
  }

  @protected
  Future<void> setupNativeViewInternal(int nativeViewPtr) async {
  }

  @override
  Future<void> setupView(int nativeViewPtr) async {
    if (_isCreatedRender) {
      return;
    }

    await setupNativeViewInternal(nativeViewPtr);

    _isCreatedRender = true;
  }

  @override
  Future<int> createTextureRender(
      int uid, String channelId, int videoSourceType, int videoViewSetupMode) async {

    if (_isCreatedRender) {
      return _textureId;
    }
    // final textureId =
    //     await createTextureRender(
    //   uid,
    //   channelId,
    //   videoSourceType,
    //   videoViewSetupMode,
    // );
    //
    // _isCreatedRender = true;
    // _isDisposeRender = false;

    return _textureId;
  }

  @internal
  bool get shouldHandlerRenderMode => true;
}
