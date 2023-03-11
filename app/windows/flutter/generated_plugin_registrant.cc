//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_tts/flutter_tts_plugin.h>
#include <tflite_flutter_helper/tflite_flutter_helper_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterTtsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterTtsPlugin"));
  TfliteFlutterHelperPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TfliteFlutterHelperPlugin"));
}
