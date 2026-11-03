import 'dart:typed_data';

import 'card_download_stub.dart'
    if (dart.library.js_interop) 'card_download_web.dart';

void downloadCardImage(Uint8List bytes, String fileName) {
  triggerFileDownload(bytes, fileName);
}

void openCardImage(Uint8List bytes) {
  triggerOpenInNewTab(bytes);
}
