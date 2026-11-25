import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/saved_character_actions.dart';

enum SavedStatus { loading, ready, failure }

class SavedCharactersState extends Equatable {
  const SavedCharactersState({
    this.status = SavedStatus.loading,
    this.characters = const [],
    this.error,
  });

  final SavedStatus status;
  final List<Character> characters;
  final String? error;

  SavedCharactersState copyWith({
    SavedStatus? status,
    List<Character>? characters,
    Object? error = _keep,
  }) {
    return SavedCharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [status, characters, error];
}

const _keep = Object();

sealed class SavedCharactersEvent extends Equatable {
  const SavedCharactersEvent();

  @override
  List<Object?> get props => [];
}

class SavedStarted extends SavedCharactersEvent {
  const SavedStarted();
}

class SavedRefreshed extends SavedCharactersEvent {
  const SavedRefreshed();
}

class SavedCharactersBloc
    extends Bloc<SavedCharactersEvent, SavedCharactersState> {
  SavedCharactersBloc({required this.phone, required this.getSavedCharacters})
    : super(const SavedCharactersState()) {
    on<SavedStarted>(_load);
    on<SavedRefreshed>(_load);
  }

  final String phone;
  final GetSavedCharacters getSavedCharacters;

  Future<void> _load(
    SavedCharactersEvent event,
    Emitter<SavedCharactersState> emit,
  ) async {
    if (state.characters.isEmpty) {
      emit(state.copyWith(status: SavedStatus.loading, error: null));
    }
    final result = await getSavedCharacters(PhoneParams(phone));
    result.fold(
      (failure) => emit(
        state.copyWith(status: SavedStatus.failure, error: failure.message),
      ),
      (characters) => emit(
        SavedCharactersState(status: SavedStatus.ready, characters: characters),
      ),
    );
  }
}
