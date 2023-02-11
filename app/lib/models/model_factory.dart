enum SerializedStatus {
  unSerialized,
  serialized,
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
/// ### 2. Define model instance
///
/// ```dart
/// final serialized = ModelFactory(ExampleModel());
/// ```
/// ---
/// ### 3. Serialize json list to model
///
/// Serialize `json` **list** to your `Model` **list**
///   ```dart
///   final exampleJsonList = await fetch("...FetchURL");
///   serialized.serializeList(exampleJsonList);
///   ```
/// Serialize `json` to your `Model`
///   ```dart
///   final exampleJson = await fetch("...FetchURL");
///   serialized.serialize(exampleJson);
///   ```
/// ---
/// ### 4. Access data
///
/// Access serialized model with `data(jsonMap)` or `dataList(list of jsonMap)` property
/// ```dart
/// print(serialized.dataList[0].id);
/// // 2
/// ```
class ModelFactory<ModelType extends Model<ModelType>> {
  static const String nullish = "NULLISH";

  SerializedStatus status = SerializedStatus.unSerialized;
  final ModelType model;
  final List<ModelType> dataList = [];
  ModelType get data {
    return dataList[0];
  }

  ModelFactory(this.model);

  void _updateSerializedStatus() {
    if (dataList.isNotEmpty) {
      status = SerializedStatus.serialized;
    } else {
      status = SerializedStatus.unSerialized;
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
  void serialize(Map<String, dynamic>? jsonMap) {
    if (jsonMap != null) {
      print(_createModelInstance(jsonMap));
      _updateDataList(
        [_createModelInstance(jsonMap)],
      );
    }

    _updateSerializedStatus();
  }

  /// transform `List<JsonMap>` to `List<ModelType>`
  void serializeList(List<dynamic>? jsonMapList) {
    if (jsonMapList != null) {
      final List<ModelType> modelList = jsonMapList
          .map(
            (json) => _createModelInstance(json),
          )
          .toList();

      _updateDataList(modelList);
    }

    _updateSerializedStatus();
  }
}
