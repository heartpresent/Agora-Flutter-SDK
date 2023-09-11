import 'package:agora_rtc_engine/src/web/impl/rtc_renderer.dart';
import 'package:agora_rtc_engine/src/web/render/rtc_render_view.dart';
import 'package:agora_rtc_engine/src/web/render/video_view_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Callback when [AgoraVideoView] created.
typedef AgoraVideoViewCreatedCallback = void Function(int viewId);

class AgoraVideoViewState extends State<AgoraVideoView> {
  @override
  Widget build(BuildContext context) {
    return AgoraRtcSurfaceView(
      key: widget.key,
      controller: widget.controller,
      onAgoraVideoViewCreated: widget.onAgoraVideoViewCreated,
    );
  }
}

class AgoraRtcSurfaceView extends StatefulWidget {
  const AgoraRtcSurfaceView({
    Key? key,
    required this.controller,
    this.onAgoraVideoViewCreated,
  }) : super(key: key);

  final VideoViewControllerBase controller;

  final AgoraVideoViewCreatedCallback? onAgoraVideoViewCreated;

  @override
  _AgoraRtcRenderSurfaceViewState createState() =>
      _AgoraRtcRenderSurfaceViewState();
}

class _AgoraRtcRenderSurfaceViewState extends State<AgoraRtcSurfaceView>
    with RtcRenderMixin {
  int? _id;

  final Map<int, MethodChannel> _channels = {};
  MethodChannel? methodChannel;

  @override
  Widget build(BuildContext context) {
    return buildPlatformView(onPlatformViewCreated: (int id) {
      _setData(id);
    });
  }

  Future<void> _setData(int id) async {
    _id = id;

    print('jason id : $id');
    if (!_channels.containsKey(id)) {
      _channels[id] = MethodChannel('agora_rtc_engine/surface_view_$id');
    }

    var params = <String, dynamic>{
      'userId': 0,
      'channelId': "1234",
    };

    params['subProcess'] = false;

    _channels[id]?.invokeMethod('setData', params);
  }

  @override dispose() {
    super.dispose();
    _channels.remove(_id);
  }
}
