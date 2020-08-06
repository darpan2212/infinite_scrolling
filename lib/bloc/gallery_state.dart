import 'package:infinite_scroll/models/nodes_model.dart';

abstract class GalleryState {}

class GalleryInit extends GalleryState {}

class GalleryDataSuccess extends GalleryState {
  final NodesModel nodesData;
  final bool hasMaxData;

  GalleryDataSuccess(this.nodesData, {this.hasMaxData = false});
}

class GalleryDataFailure extends GalleryState {
  final String failureMsg;

  GalleryDataFailure(this.failureMsg);
}
