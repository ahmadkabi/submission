part of 'movie_detail_bloc.dart';

class MovieDetailState extends Equatable {
  final RequestState movieState;
  final RequestState recommendationState;
  final MovieDetail? movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;
  final String message;
  final String watchlistMessage;

  const MovieDetailState({
    this.movieState = RequestState.Empty,
    this.recommendationState = RequestState.Empty,
    this.movie,
    this.recommendations = const [],
    this.isAddedToWatchlist = false,
    this.message = '',
    this.watchlistMessage = '',
  });

  MovieDetailState copyWith({
    RequestState? movieState,
    RequestState? recommendationState,
    MovieDetail? movie,
    List<Movie>? recommendations,
    bool? isAddedToWatchlist,
    String? message,
    String? watchlistMessage,
  }) {
    return MovieDetailState(
      movieState: movieState ?? this.movieState,
      recommendationState:
          recommendationState ?? this.recommendationState,
      movie: movie ?? this.movie,
      recommendations: recommendations ?? this.recommendations,
      isAddedToWatchlist:
          isAddedToWatchlist ?? this.isAddedToWatchlist,
      message: message ?? this.message,
      watchlistMessage:
          watchlistMessage ?? this.watchlistMessage,
    );
  }

  @override
  List<Object?> get props => [
        movieState,
        recommendationState,
        movie,
        recommendations,
        isAddedToWatchlist,
        message,
        watchlistMessage,
      ];
}

/*
part of 'movie_detail_bloc.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();
 
  @override
  List<Object> get props => [];
}
 
class Loading extends MovieDetailState {}
 
class Error extends MovieDetailState {
  final String message;
 
  Error(this.message);
 
  @override
  List<Object> get props => [message];
}
 
class Success extends MovieDetailState {
  final Movie result;
 
  Success(this.result);
 
  @override
  List<Object> get props => [result];
}

*/