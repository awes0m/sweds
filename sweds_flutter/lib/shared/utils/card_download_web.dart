import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void triggerFileDownload(Uint8List bytes, String fileName) {
  final mimeType = fileName.toLowerCase().endsWith('.pdf')
      ? 'application/pdf'
      : 'image/png';
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

void triggerOpenInNewTab(Uint8List bytes, [String fileName = 'card.png']) {
  final mimeType = fileName.toLowerCase().endsWith('.pdf')
      ? 'application/pdf'
      : 'image/png';
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
