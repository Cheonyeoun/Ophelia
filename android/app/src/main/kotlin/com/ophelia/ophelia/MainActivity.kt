package com.ophelia.ophelia

import com.ryanheise.audioservice.AudioServiceActivity

// Extends audio_service's AudioServiceActivity (itself a FlutterActivity)
// instead of FlutterActivity directly, so this activity shares its
// FlutterEngine with the AudioService background service declared in
// AndroidManifest.xml -- see
// https://pub.dev/packages/audio_service#custom-android-activity.
class MainActivity : AudioServiceActivity()
