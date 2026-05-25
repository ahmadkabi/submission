import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/provider/watchlist_tv_notifier.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchlistPage extends StatefulWidget {
  static const ROUTE_NAME = '/watchlist-tv';

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<WatchlistTvNotifier>(context, listen: false)
          ..fetchWatchlistMovies()
          ..fetchWatchlistTvs());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void didPopNext() {
    Provider.of<WatchlistTvNotifier>(context, listen: false)
      ..fetchWatchlistMovies()
      ..fetchWatchlistTvs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<WatchlistTvNotifier>(
          builder: (context, data, child) {
            if (data.watchlistStateTv == RequestState.Loading ||
                data.watchlistStateMovie == RequestState.Loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (data.watchlistStateTv == RequestState.Loaded &&
                data.watchlistStateMovie == RequestState.Loaded) {
              return ListView(
                children: [
                  if (data.watchlistMovies.isNotEmpty) ...[
                    Text(
                      "Movie Watchlist",
                      style: kHeading6,
                    ),
                    ...data.watchlistMovies.map(
                      (movie) => MovieCard(movie),
                    ),
                  ],
                  if (data.watchlistTvs.isNotEmpty) ...[
                    Text(
                      "Tv Watchlist",
                      style: kHeading6,
                    ),
                    ...data.watchlistTvs.map(
                      (tv) => TvCard(tv),
                    ),
                  ],
                ],
              );
            } else {
              return Center(
                key: Key('error_message'),
                child: Text(data.messageTv),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
