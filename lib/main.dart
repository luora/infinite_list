

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list/posts/bloc/post_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_list/posts/bloc/post_event.dart';
import 'package:infinite_list/posts/bloc/post_state.dart';
import 'package:infinite_list/posts/models/models.dart';

import 'bloc_observer.dart';

void main() {
  BlocOverrides.runZoned(
      () => runApp(const App()),
    blocObserver: SimpleBlocObserver()
  );

}

class App extends MaterialApp{
  const App({Key? key}) : super(
    key: key,
    home: const PostsPage()
  );

}

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Posts'),),
      body: BlocProvider(
          create: (_) => PostBloc( httpClient: http.Client(),)..add(PostFetched()),
          child: PostsList(),
      ),
    );
  }
}

class PostsList extends StatefulWidget {


  const PostsList({Key? key}) : super(key: key);

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
  }



  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PostBloc, PostState>(
        builder: (context, state){
           switch (state.status){





             case PostStatus.failure: 
               return const Center(
                 child: Text('failed '),
               );
             case PostStatus.success:
               print("post success");
               if(state.posts.isEmpty){
                 return const Center(
                   child: Text('no posts'),
                 );
               }
               return ListView.builder(

                   itemBuilder: (BuildContext context, int index ){
                     print("posts length : ${state.posts.length}");
                     return index >= state.posts.length ?
                         BottomLoader():
                         PostListItem(post:state.posts[index]);

                   },

                 itemCount: state.hasReachedMax
                              ? state.posts.length
                              : state.posts.length + 1,
                 controller: _scrollController,

               );

             default:
               print("default");
               return const Center(
                 child: CircularProgressIndicator(),
               );
               
           }
        }
    );
  }
  
  void _onScroll() {
    if(_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {

    if(!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
    
  }

  @override
  void dispose(){
    _scrollController..removeListener(_onScroll)..dispose();
    super.dispose();

  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(),
    );
  }
}

class PostListItem extends StatelessWidget {
  const PostListItem({Key? key,required this.post}) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${post.id}', style: textTheme.caption,),
        title: Text(post.title),
        subtitle: Text(post.body),
        dense: true,
        isThreeLine: true

      )
    );
  }
}


