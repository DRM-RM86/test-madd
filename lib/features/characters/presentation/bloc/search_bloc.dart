import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pruebatecnica/features/characters/data/datasources/workspace_store.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/saved_character_actions.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/search_characters.dart';

enum SearchStatus { idle, loading, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.characters = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.savedIds = const [],
    this.error,
  });

  final SearchStatus status;
  final String query;
  final List<Character> characters;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final List<int> savedIds;
  final String? error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Character>? characters,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    List<int>? savedIds,
    Object? error = _keep,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      characters: characters ?? this.characters,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      savedIds: savedIds ?? this.savedIds,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    characters,
    page,
    hasMore,
    loadingMore,
    savedIds,
    error,
  ];
}

const _keep = Object();

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  const SearchStarted();
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchNextPage extends SearchEvent {
  const SearchNextPage();
}

class SearchMarksRefresh extends SearchEvent {
  const SearchMarksRefresh();
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required this.phone,
    required this.searchCharacters,
    required this.getSavedIds,
    required this.workspace,
  }) : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchNextPage>(_onNextPage);
    on<SearchMarksRefresh>(_onMarks);
  }

  final String phone;
  final SearchCharacters searchCharacters;
  final GetSavedIds getSavedIds;
  final WorkspaceStore workspace;

  Future<void> _onMarks(
    SearchMarksRefresh event,
    Emitter<SearchState> emit,
  ) async {
    final result = await getSavedIds(PhoneParams(phone));
    result.fold((_) {}, (ids) => emit(state.copyWith(savedIds: ids)));
  }

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    final query = await workspace.readQuery(phone);
    emit(state.copyWith(query: query));
    if (query.trim().isEmpty) return;
    await _search(query, 1, emit);
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    await workspace.saveQuery(phone, query);
    if (query.isEmpty) {
      emit(
        const SearchState(
          status: SearchStatus.idle,
          error: 'Escribe un nombre.',
        ),
      );
      return;
    }
    await _search(query, 1, emit);
  }

  Future<void> _onNextPage(
    SearchNextPage event,
    Emitter<SearchState> emit,
  ) async {
    if (!state.hasMore ||
        state.loadingMore ||
        state.status == SearchStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true, error: null));
    await _search(state.query, state.page + 1, emit);
  }

  Future<void> _search(
    String query,
    int page,
    Emitter<SearchState> emit,
  ) async {
    if (page == 1) {
      emit(
        state.copyWith(
          status: SearchStatus.loading,
          query: query,
          characters: const [],
          loadingMore: false,
          error: null,
        ),
      );
    }

    final result = await searchCharacters(
      SearchCharactersParams(name: query, page: page),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: page == 1 ? SearchStatus.failure : state.status,
          loadingMore: false,
          error: failure.message,
        ),
      ),
      (characterPage) {
        final characters = page == 1
            ? characterPage.characters
            : [...state.characters, ...characterPage.characters];
        emit(
          state.copyWith(
            status: characters.isEmpty
                ? SearchStatus.empty
                : SearchStatus.success,
            query: query,
            characters: characters,
            page: page,
            hasMore: characterPage.hasMore,
            loadingMore: false,
            error: null,
          ),
        );
      },
    );
    final marks = await getSavedIds(PhoneParams(phone));
    marks.fold((_) {}, (ids) => emit(state.copyWith(savedIds: ids)));
  }
}
