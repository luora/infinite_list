
import 'package:equatable/equatable.dart';

import '../models/models.dart';

enum PostStatus {initial, success, failure}

class PostState extends Equatable{

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false
  });

  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    bool? hasReachedMax
}){
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax
    );
  }

  @override
  String toString(){
    return ''' PostState { status: $status, hasReachedMax: $hasReachedMax}, posts: ${posts.length}''';
  }

  @override
  // TODO: implement props
  List<Object> get props => [status, posts, hasReachedMax];

}