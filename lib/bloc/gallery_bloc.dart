import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll/bloc/gallery_event.dart';
import 'package:infinite_scroll/bloc/gallery_state.dart';
import 'package:infinite_scroll/common/app_constant.dart';
import 'package:infinite_scroll/models/nodes_model.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  int nextPage = 0;

  GalleryBloc() : super(GalleryInit());

  bool _hasMaxData(GalleryState state) =>
      state is GalleryDataSuccess && state.hasMaxData;

  @override
  Stream<GalleryState> mapEventToState(GalleryEvent event) async* {
    final currentState = state;
    if (event is GalleryFetch && !_hasMaxData(currentState)) {
      try {
        if (currentState is GalleryInit) {
          NodesModel nodesData = await fetchImages(nextPage);
          yield GalleryDataSuccess(nodesData);
          return;
        } else if (currentState is GalleryDataSuccess) {
          NodesModel nodesData = await fetchImages(++nextPage);
          List<Nodes> previousNodes = currentState.nodesData.nodes;
          if (nodesData.nodes.isNotEmpty) {
            nodesData.nodes = previousNodes + nodesData.nodes;
            yield GalleryDataSuccess(nodesData);
          } else {
            nodesData.nodes = previousNodes;
            yield GalleryDataSuccess(
              nodesData,
              hasMaxData: true,
            );
          }
          return;
        } else {
          return;
        }
      } catch (e) {
        print(e.toString());
        yield GalleryDataFailure(e.toString());
        return;
      }
    }
    return;
  }

  Future<NodesModel> fetchImages(int nextPage) async {
    String url = '${AppConstant.baseUrl}$nextPage';
    print(url);
    http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      print(json.decode(res.body));
      NodesModel nodesData = NodesModel.fromJson(json.decode(res.body));
      return nodesData;
    } else {
      print('No Response Data');
      throw Exception('No Response Data');
    }
  }
}
