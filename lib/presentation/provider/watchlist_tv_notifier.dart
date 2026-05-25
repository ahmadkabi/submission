import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_watchlist_movies.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tvs.dart';
import 'package:flutter/foundation.dart';

class WatchlistTvNotifier extends ChangeNotifier {
  var _watchlistTvs = <Tv>[];
  List<Tv> get watchlistTvs => _watchlistTvs;

  var _watchlistMovies = <Movie>[];
  List<Movie> get watchlistMovies => _watchlistMovies;

  var _watchlistStateTv = RequestState.Empty;
  RequestState get watchlistStateTv => _watchlistStateTv;

  var _watchlistStateMovie = RequestState.Empty;
  RequestState get watchlistStateMovie => _watchlistStateMovie;

  String _messageTv = '';
  String get messageTv => _messageTv;

  String _messageMovie = '';
  String get messageMovie => _messageMovie;

  WatchlistTvNotifier(
      {required this.getWatchlistTvs, required this.getWatchlistMovies});

  final GetWatchlistTvs getWatchlistTvs;
  final GetWatchlistMovies getWatchlistMovies;

  Future<void> fetchWatchlistTvs() async {
    _watchlistStateTv = RequestState.Loading;
    notifyListeners();

    final result = await getWatchlistTvs.execute();
    result.fold(
      (failure) {
        _watchlistStateTv = RequestState.Error;
        _messageTv = failure.message;
        notifyListeners();
      },
      (tvsData) {
        _watchlistStateTv = RequestState.Loaded;
        _watchlistTvs = tvsData;
        notifyListeners();
      },
    );
  }

  Future<void> fetchWatchlistMovies() async {
    _watchlistStateMovie = RequestState.Loading;
    notifyListeners();

    final result = await getWatchlistMovies.execute();
    result.fold(
      (failure) {
        _watchlistStateMovie = RequestState.Error;
        _messageMovie = failure.message;
        notifyListeners();
      },
      (moviesData) {
        _watchlistStateMovie = RequestState.Loaded;
        _watchlistMovies = moviesData;
        notifyListeners();
      },
    );
  }
}
