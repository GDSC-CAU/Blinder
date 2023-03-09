import 'package:app/models/model_factory.dart';
import 'package:app/models/ocr_menu_block.dart';
import 'package:app/services/core/api_service.dart';

class OcrService {
  static const serviceUrl = "https://blinder-379706.du.r.appspot.com/ocr";

  final _ocrMenuBlockModel = ModelFactory(OcrMenuBlock());
  final List<OcrMenuBlock> ocrMenuBlockList = [];

  final _ocrService = ApiService(
    baseUrl: serviceUrl,
  );

  void _updateOcrMenuBlockList(List<OcrMenuBlock> newOcrMenuBlockList) {
    if (ocrMenuBlockList.isNotEmpty) ocrMenuBlockList.clear();
    ocrMenuBlockList.addAll(newOcrMenuBlockList);
  }

  Future<void> uploadImage({
    required String imagePath,
    required String fileName,
  }) async {
    try {
      final responseJson = await _ocrService.postImage(
        imagePath: imagePath,
        imageKey: "file",
        fileName: fileName,
      );

      if (responseJson == null) return;

      final ocrBlock = responseJson["data"];
      if (ocrBlock == null) return;
      _ocrMenuBlockModel.serializeList(ocrBlock as List<dynamic>);
      _updateOcrMenuBlockList(_ocrMenuBlockModel.dataList);
    } catch (e) {
      throw Exception(e);
    }
  }
}
