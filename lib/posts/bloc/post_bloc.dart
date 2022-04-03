
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list/posts/bloc/post_event.dart';
import 'package:infinite_list/posts/bloc/post_state.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

import '../models/models.dart';

class PostBloc extends Bloc<PostEvent, PostState>{

  final  int _postLimit = 10;
  final http.Client httpClient;

  static const throttleDuration = Duration(milliseconds: 200);

  PostBloc({required this.httpClient}):super(const PostState()){
    on<PostFetched>(
        _onPostsFetched,
      transformer: throttleDroppable(throttleDuration)
    );
  }

  EventTransformer<E> throttleDroppable<E>(Duration duration){
    return (events, mapper){
      return droppable<E>().call(events.throttle(duration), mapper);
    };
  }


  Future<void> _onPostsFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;

    try{

      if (state.status == PostStatus.initial){
        final posts = await _fetchPosts();

        return emit(state.copyWith(
          status: PostStatus.success,
          posts: posts,
          hasReachedMax: false
        ));
      }

      print("fetch another");

      final posts = await _fetchPosts(state.posts.length);

      //print(posts);
      print("post empty : ${posts.isEmpty}");

      //List<Post> postsf = state.posts..addAll(posts);

      // emit(
      //     state.copyWith(
      //           status: PostStatus.success,
      //           posts: postsf,
      //           hasReachedMax: false
      //     ));
      //

      // posts.isNotEmpty
      //         ?  emit(
      //     state.copyWith(
      //         status: PostStatus.success,
      //         posts: postsf,
      //         hasReachedMax: false
      //     )): emit(state.copyWith(hasReachedMax: true));

      emit(posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
        status: PostStatus.success,
        posts: List.of(state.posts)..addAll(posts),
        hasReachedMax: false,
      ));


      print(state.hasReachedMax);

      print("after emit posts length: ${state.posts.length}");

    } catch(_) {
      print("something failed");
      emit(
        state.copyWith(
          status: PostStatus.failure
        )
      );
    }


  }

  Future<List<Post>> _fetchPosts([int _startIndex = 0]) async {

    print("start index : $_startIndex");

    final response = await httpClient.get(
      Uri.https(
          'jsonplaceholder.typicode.com',
          '/posts',
        <String, String>{'_start':'$_startIndex', '_limit':'$_postLimit'}
      )
    );

    if(response.statusCode == 200) {

      print("  status code ${response.statusCode}");

      final body = json.decode(response.body) as List;

      return body.map((dynamic json) {
        return Post(
            id: json['id'] as int,
            title: json['title'] as String,
            body: json['body'] as String);
      }).toList();
    }
    throw Exception('error fetching posts');
  }



}