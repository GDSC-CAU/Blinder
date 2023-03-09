import 'dart:io';
import 'dart:math';

import 'package:app/core/block/block.dart';
import 'package:app/core/block/menu_block.dart';
import 'package:app/core/menu_engine.dart';
import 'package:app/models/ocr_menu_block.dart';
import 'package:app/services/ocr.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

enum NetworkStatus {
  online,
  offline,
}

class MenuBlockParser {
  final OcrService _ocrService = OcrService();
  final TextRecognizer _mlKitTextRecognizer;

  NetworkStatus _networkStatus = NetworkStatus.offline;

  MenuBlockList menuBlockList = [];

  MenuBlockParser()
      : _mlKitTextRecognizer = GoogleMlKit.vision.textRecognizer(
          script: TextRecognitionScript.korean,
        );

  Future<void> _setNetworkState() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (isOnline) {
        _networkStatus = NetworkStatus.online;
      } else {
        _networkStatus = NetworkStatus.offline;
      }
    } on SocketException catch (_) {
      _networkStatus = NetworkStatus.offline;
      return;
    }
  }

  MenuBlockList _getMenuRectBlockListFromMLKit(
    RecognizedText recognizedText,
  ) {
    final MenuBlockList transformedMenuBlockList = [];

    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        for (final TextElement element in line.elements) {
          transformedMenuBlockList.add(
            MenuBlock(
              text: element.text,
              block: Block(
                initialPosition: RectPosition(
                  tl: Coord(
                    x: element.cornerPoints[0].x,
                    y: element.cornerPoints[0].y,
                  ),
                  tr: Coord(
                    x: element.cornerPoints[1].x,
                    y: element.cornerPoints[1].y,
                  ),
                  br: Coord(
                    x: element.cornerPoints[2].x,
                    y: element.cornerPoints[2].y,
                  ),
                  bl: Coord(
                    x: element.cornerPoints[3].x,
                    y: element.cornerPoints[3].y,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return transformedMenuBlockList;
  }

  Future<void> _parseOffline(
    String imagePath,
  ) async {
    final image = InputImage.fromFilePath(imagePath);

    final recognizedText = await _mlKitTextRecognizer.processImage(image);
    _mlKitTextRecognizer.close();

    menuBlockList = _getMenuRectBlockListFromMLKit(
      recognizedText,
    );
  }

  MenuBlockList _getMenuBlockListFromOcrServer(
    List<OcrMenuBlock> ocrMenuBlockList,
  ) =>
      ocrMenuBlockList.fold<MenuBlockList>(
        [],
        (menuBlockList, ocrMenuBlock) {
          final menuBlock = MenuBlock(
            text: ocrMenuBlock.text,
            block: Block(
              initialPosition: RectPosition(
                tl: ocrMenuBlock.tl,
                tr: ocrMenuBlock.tr,
                br: ocrMenuBlock.br,
                bl: ocrMenuBlock.bl,
              ),
            ),
          );
          menuBlockList.add(menuBlock);
          return menuBlockList;
        },
      );

  Future<void> _parseOnline(
    String imagePath,
  ) async {
    final randomFileName =
        "menu-image-$imagePath-${Random.secure().nextInt(100000000)}";

    await _ocrService.uploadImage(
      imagePath: imagePath,
      fileName: randomFileName,
    );

    menuBlockList = _getMenuBlockListFromOcrServer(
      _ocrService.ocrMenuBlockList,
    );
  }

  /// parse `MenuBlockList` based on user network status
  ///
  /// - `NetworkStatus.online`: get data from `ocr server`
  /// - `NetworkStatus.offline`: get data from `MLKit`
  Future<void> parse(
    String imagePath,
  ) async {
    await _setNetworkState();

    if (_networkStatus == NetworkStatus.offline) {
      await _parseOffline(imagePath);
      return;
    }
    await _parseOnline(imagePath);
  }
}
