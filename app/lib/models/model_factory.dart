enum TransformStatus {
  unTransformed,
  transformed,
}

typedef JsonMap = Map<String, dynamic>;

abstract class Model<ModelType> {
  void set(JsonMap jsonMap) {}
  ModelType create();
}

/// ### 1. Define model class
///
/// implements `Model`
/// `get` method is logic of saving data
/// ```dart
/// class ExampleModel implements Model<ExampleModel> {
///   int id = 0;
///
///   @override
///   get(json){
///     id = int.parse(json["id"]);
///   }
///   /// create instance
///   @override
///   create(){
///     return ExampleModel();
///   }
/// }
/// ```
/// ---
/// ### 2. Define model instance typed data
///
/// ```dart
/// final dataList = ModelFactory(ExampleModel());
/// ```
/// ---
/// ### 3. Transform json list to model list
///
/// Get `json` list
///   ```dart
///   final exampleJsonList = await fetch("...FetchURL");
///   ```
/// Transform `json` list to your `Model`
///   ```dart
///   dataList.transform(exampleJsonList);
///   ```
/// ---
/// ### 4. Access data
///
/// Access transformed model with `data(jsonMap)` or `dataList(list of jsonMap)` property
/// ```dart
/// print(dataList.data[0].id);
/// // 2
/// print(data.id);
/// // 3213
/// ```
class ModelFactory<ModelType extends Model<ModelType>> {
  static const String nullish = "NULLISH";

  TransformStatus status = TransformStatus.unTransformed;
  final ModelType model;
  final List<ModelType> dataList = [];
  ModelType get data {
    return dataList[0];
  }

  ModelFactory(this.model);

  void _updateStatus() {
    if (dataList.isNotEmpty) {
      status = TransformStatus.transformed;
    } else {
      status = TransformStatus.unTransformed;
    }
  }

  void _updateDataList(List<ModelType> modelList) {
    if (modelList.isEmpty == false) dataList.addAll(modelList);
  }

  /// create `ModelType` instance from `Json`
  ModelType _createModelInstance(dynamic json) {
    final modelKeys = (json as JsonMap).keys.toList();

    final jsonMap = modelKeys.fold<JsonMap>(
      {},
      (accJsonMap, key) {
        if (json[key] != null) {
          accJsonMap[key] = json[key];
          return accJsonMap;
        }
        accJsonMap[key] = nullish;
        return accJsonMap;
      },
    );

    final ModelType modelInstance = model.create();
    modelInstance.set(jsonMap);

    return modelInstance;
  }

  /// transform `JsonMap` to `ModelType`
  void transformJson(Map<String, dynamic>? jsonMap) {
    if (jsonMap != null) {
      print(_createModelInstance(jsonMap));
      _updateDataList(
        [_createModelInstance(jsonMap)],
      );
    }

    _updateStatus();
  }

  /// transform `List<JsonMap>` to `List<ModelType>`
  void transformJsonList(List<dynamic>? jsonMapList) {
    if (jsonMapList != null) {
      final List<ModelType> modelList = jsonMapList
          .map(
            (json) => _createModelInstance(json),
          )
          .toList();

      _updateDataList(modelList);
    }

    _updateStatus();
  }
}
