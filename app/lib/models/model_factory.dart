enum SerializedStatus {
  unSerialized,
  serialized,
}

typedef JsonMap = Map<String, dynamic>;

abstract class Model<ModelType> {
  void set(JsonMap jsonMap) {}
  ModelType create();
  JsonMap toJson();
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

  /// Instance of target `model`
  final ModelType model;

  /// List of initial `JsonMap`
  final List<JsonMap> jsonList = [];

  /// Single `JsonMap`
  JsonMap? get json {
    return jsonList.isEmpty ? null : jsonList.first;
  }

  /// List of `ModelType`
  final List<ModelType> dataList = [];

  /// Single `ModelType`
  ModelType? get data {
    return dataList.isEmpty ? null : dataList.first;
  }

  ModelFactory(this.model);

  void _updateSerializedStatus() {
    if (dataList.isNotEmpty) {
      status = SerializedStatus.serialized;
    } else {
      status = SerializedStatus.unSerialized;
    }
  }

  void _updateJsonList(JsonMap jsonMap) {
    if (jsonMap.isNotEmpty) {
      jsonList.add(jsonMap);
    }
  }

  void _updateDataList(ModelType model) {
    if (model.runtimeType == ModelType) {
      dataList.add(model);
    }
  }

  JsonMap _createModelJson(dynamic json) {
    final modelKeys = (json as JsonMap).keys.toList();

    final modelJsonMap = modelKeys.fold<JsonMap>(
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

    return modelJsonMap;
  }

  /// create `ModelType` instance from `Json`
  ModelType _createModelInstance(JsonMap jsonMap) {
    final ModelType modelInstance = model.create();
    modelInstance.set(jsonMap);

    return modelInstance;
  }

  void _clearData() {
    jsonList.clear();
    dataList.clear();
  }

  /// serialize `JsonMap` to `ModelType`
  void serialize(
    Map<String, dynamic>? jsonMap, {
    bool? enableSerializeStatusUpdate = true,
  }) {
    if (enableSerializeStatusUpdate == true) _clearData();

    if (jsonMap != null) {
      final modelJsonMap = _createModelJson(jsonMap);
      final modelInstance = _createModelInstance(modelJsonMap);

      _updateJsonList(modelJsonMap);
      _updateDataList(modelInstance);
    }

    if (enableSerializeStatusUpdate == true) _updateSerializedStatus();
  }

  /// serialize `List<JsonMap>` to `List<ModelType>`
  void serializeList(List<dynamic>? jsonMapList) {
    if (jsonMapList != null) {
      _clearData();

      for (final jsonMap in jsonMapList) {
        serialize(
          jsonMap as JsonMap,
          enableSerializeStatusUpdate: false,
        );
      }
    }

    _updateSerializedStatus();
  }

  /// Deserialize `Model` to `JsonMap`
  static JsonMap deserialize(Model model) => model.toJson();

  /// Deserialize `List<Model>` to `List<JsonMap>`
  static List<JsonMap> deserializeList(List<Model> models) =>
      models.map((model) => model.toJson()).toList();
}
