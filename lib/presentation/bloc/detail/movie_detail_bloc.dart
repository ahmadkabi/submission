import 'package:bloc/bloc.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status_movie.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_movie.dart';
import 'package:ditonton/domain/usecases/save_watchlist_movie.dart';
import 'package:equatable/equatable.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc
    extends Bloc<MovieDetailEvent, MovieDetailState> {
  static const watchlistAddSuccessMessage =
      'Added to Watchlist';

  static const watchlistRemoveSuccessMessage =
      'Removed from Watchlist';

  final GetMovieDetail getMovieDetail;
  final GetMovieRecommendations getMovieRecommendations;
  final GetWatchListStatusMovie getWatchListStatus;
  final SaveWatchlistMovie saveWatchlist;
  final RemoveWatchlistMovie removeWatchlist;

  MovieDetailBloc({
    required this.getMovieDetail,
    required this.getMovieRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(const MovieDetailState()) {
    on<FetchMovieDetail>(_onFetchMovieDetail);
    on<LoadWatchlistStatus>(_onLoadWatchlistStatus);
    on<AddWatchlist>(_onAddWatchlist);
    on<RemoveWatchlist>(_onRemoveWatchlist);
  }

  Future<void> _onFetchMovieDetail(
    FetchMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        movieState: RequestState.Loading,
      ),
    );

    final detailResult =
        await getMovieDetail.execute(event.id);

    final recommendationResult =
        await getMovieRecommendations.execute(event.id);

    await detailResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            movieState: RequestState.Error,
            message: failure.message,
          ),
        );
      },
      (movie) async {
        emit(
          state.copyWith(
            movie: movie,
            recommendationState:
                RequestState.Loading,
          ),
        );

        recommendationResult.fold(
          (failure) {
            emit(
              state.copyWith(
                recommendationState:
                    RequestState.Error,
                message: failure.message,
              ),
            );
          },
          (movies) {
            emit(
              state.copyWith(
                movieState: RequestState.Loaded,
                recommendationState:
                    RequestState.Loaded,
                movie: movie,
                recommendations: movies,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onAddWatchlist(
    AddWatchlist event,
    Emitter<MovieDetailState> emit,
  ) async {
    final result =
        await saveWatchlist.execute(event.movie);

    final message = result.fold(
      (failure) => failure.message,
      (success) => success,
    );

    final status =
        await getWatchListStatus.execute(event.movie.id);

    emit(
      state.copyWith(
        watchlistMessage: message,
        isAddedToWatchlist: status,
      ),
    );
  }

  Future<void> _onRemoveWatchlist(
    RemoveWatchlist event,
    Emitter<MovieDetailState> emit,
  ) async {
    final result =
        await removeWatchlist.execute(event.movie);

    final message = result.fold(
      (failure) => failure.message,
      (success) => success,
    );

    final status =
        await getWatchListStatus.execute(event.movie.id);

    emit(
      state.copyWith(
        watchlistMessage: message,
        isAddedToWatchlist: status,
      ),
    );
  }

  Future<void> _onLoadWatchlistStatus(
    LoadWatchlistStatus event,
    Emitter<MovieDetailState> emit,
  ) async {
    final status =
        await getWatchListStatus.execute(event.id);

    emit(
      state.copyWith(
        isAddedToWatchlist: status,
      ),
    );
  }
}

/**
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status_movie.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_movie.dart';
import 'package:ditonton/domain/usecases/save_watchlist_movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetail _getMovieDetail;
  final GetMovieRecommendations _getMovieRecommendations;
  final GetWatchListStatusMovie _getWatchListStatus;
  final SaveWatchlistMovie _saveWatchlist;
  final RemoveWatchlistMovie _removeWatchlist;

  MovieDetailBloc(
    this._getMovieDetail,
    this._getMovieRecommendations,
    this._getWatchListStatus,
    this._saveWatchlist,
    this._removeWatchlist,
  ) : super(Loading()) {
    on<OnInitial>((event, emit) async {
      /**
       
    
    detailResult.fold(
      (failure) {
        _movieState = RequestState.Error;
        _message = failure.message;
        notifyListeners();
      },
      (movie) {
        _recommendationState = RequestState.Loading;
        _movie = movie;
        notifyListeners();
        recommendationResult.fold(
          (failure) {
            _recommendationState = RequestState.Error;
            _message = failure.message;
          },
          (movies) {
            _recommendationState = RequestState.Loaded;
            _movieRecommendations = movies;
          },
        );
        _movieState = RequestState.Loaded;
        notifyListeners();
      },
    );
       */

      emit(Loading());
      // final result = await _searchMovies.execute(query);
      final detailResult = await _getMovieDetail.execute(event.id);
      final recommendationResult =
          await _getMovieRecommendations.execute(event.id);

      detailResult.fold(
        (failure) {
          emit(Error(failure.message));
        },
        (movie) {
          emit(Success(movie));
        },
      );
    });
  }
}

*/