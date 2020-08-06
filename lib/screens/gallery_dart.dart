import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll/bloc/gallery_bloc.dart';
import 'package:infinite_scroll/bloc/gallery_event.dart';
import 'package:infinite_scroll/bloc/gallery_state.dart';
import 'package:infinite_scroll/common/app_constant.dart';

class GalleryHome extends StatefulWidget {
  @override
  _GalleryHomeState createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  ScrollController _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  GalleryBloc galleryBloc;
  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    galleryBloc = GalleryBloc()..add(GalleryFetch());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: BlocProvider(
          create: (BuildContext context) {
            return galleryBloc;
          },
          child: BlocBuilder<GalleryBloc, GalleryState>(
            builder: (_, state) {
              if (state is GalleryDataSuccess) {
                if (state.nodesData.nodes.isEmpty) {
                  return Center(
                    child: Text('No Images in Gallery'),
                  );
                }
                return ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children:
                          List.generate(state.nodesData.nodes.length, (index) {
                        String fileImage = state
                            .nodesData.nodes[index].node.fieldPhotoImageSection;
                        return CachedNetworkImage(
                          imageUrl:
                              '${AppConstant.baseNetworkImageUrl}$fileImage',
                          placeholder: (_, url) {
                            return Center(child: CircularProgressIndicator());
                          },
                          errorWidget: (context, url, error) {
                            return Icon(Icons.error);
                          },
                          repeat: ImageRepeat.repeat,
                        );
                      }),
                    ),
                    !state.hasMaxData
                        ? Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        : null,
                  ].where((element) => element != null).toList(),
                );
              }
              if (state is GalleryDataFailure) {
                return Container(
                  child: Center(
                    child: Text(
                      '${state.failureMsg}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      galleryBloc.add(GalleryFetch());
    }
  }
}
