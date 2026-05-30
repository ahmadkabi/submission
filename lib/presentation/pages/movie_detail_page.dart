import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/bloc/detail/movie_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/movie-detail';

  final int id;
  MovieDetailPage({required this.id});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MovieDetailBloc>().add(FetchMovieDetail(widget.id));
      context.read<MovieDetailBloc>().add(LoadWatchlistStatus(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state.movieState == RequestState.Loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.movieState == RequestState.Error) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state.movie == null) {
            return const SizedBox();
          }

          return SafeArea(
            child: DetailContent(
              state.movie!,
              state.recommendations,
              state.isAddedToWatchlist,
            ),
          );
        },
      ),
    );
  }
}

class DetailContent extends StatelessWidget {
  final MovieDetail movie;
  final List<Movie> recommendations;
  final bool isAddedWatchlist;

  DetailContent(this.movie, this.recommendations, this.isAddedWatchlist);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocListener<MovieDetailBloc, MovieDetailState>(
      listenWhen: (previous, current) =>
          previous.watchlistMessage != current.watchlistMessage,
      listener: (context, state) {
        final message = state.watchlistMessage;

        if (message.isEmpty) return;

        if (message == MovieDetailBloc.watchlistAddSuccessMessage ||
            message == MovieDetailBloc.watchlistRemoveSuccessMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text(message),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
              width: screenWidth,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Container(
              margin: const EdgeInsets.only(top: 48 + 8),
              child: DraggableScrollableSheet(
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: kRichBlack,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      right: 16,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: kHeading5,
                                ),
                                BlocBuilder<MovieDetailBloc, MovieDetailState>(
                                  builder: (context, state) {
                                    return FilledButton(
                                      onPressed: () {
                                        if (state.isAddedToWatchlist) {
                                          context.read<MovieDetailBloc>().add(
                                                RemoveWatchlist(movie),
                                              );
                                        } else {
                                          context.read<MovieDetailBloc>().add(
                                                AddWatchlist(movie),
                                              );
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          state.isAddedToWatchlist
                                              ? const Icon(Icons.check)
                                              : const Icon(Icons.add),
                                          const Text('Watchlist'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  _showGenres(movie.genres),
                                ),
                                Text(
                                  _showDuration(movie.runtime),
                                ),
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: movie.voteAverage / 2,
                                      itemCount: 5,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: kMikadoYellow,
                                      ),
                                      itemSize: 24,
                                    ),
                                    Text('${movie.voteAverage}')
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Overview',
                                  style: kHeading6,
                                ),
                                Text(
                                  movie.overview,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Recommendations',
                                  style: kHeading6,
                                ),
                                BlocBuilder<MovieDetailBloc, MovieDetailState>(
                                  builder: (context, state) {
                                    if (state.recommendationState ==
                                        RequestState.Loading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state.recommendationState ==
                                        RequestState.Error) {
                                      return Text(state.message);
                                    } else if (state.recommendationState ==
                                        RequestState.Loaded) {
                                      return SizedBox(
                                        height: 150,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              state.recommendations.length,
                                          itemBuilder: (context, index) {
                                            final movie =
                                                state.recommendations[index];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    MovieDetailPage.ROUTE_NAME,
                                                    arguments: movie.id,
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            color: Colors.white,
                            height: 4,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                // initialChildSize: 0.5,
                minChildSize: 0.25,
                // maxChildSize: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: kRichBlack,
                foregroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _showGenres(List<Genre> genres) {
    String result = '';
    for (var genre in genres) {
      result += genre.name + ', ';
    }

    if (result.isEmpty) {
      return result;
    }

    return result.substring(0, result.length - 2);
  }

  String _showDuration(int runtime) {
    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
