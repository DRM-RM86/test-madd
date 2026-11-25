import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/saved_character_actions.dart';

class CharacterDetailState extends Equatable {
  const CharacterDetailState({
    required this.character,
    this.saved = false,
    this.saving = false,
    this.loadingDetails = false,
    this.error,
  });

  final Character character;
  final bool saved;
  final bool saving;
  final bool loadingDetails;
  final String? error;

  CharacterDetailState copyWith({
    Character? character,
    bool? saved,
    bool? saving,
    bool? loadingDetails,
    Object? error = _keep,
  }) {
    return CharacterDetailState(
      character: character ?? this.character,
      saved: saved ?? this.saved,
      saving: saving ?? this.saving,
      loadingDetails: loadingDetails ?? this.loadingDetails,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [character, saved, saving, loadingDetails, error];
}

const _keep = Object();

sealed class CharacterDetailEvent extends Equatable {
  const CharacterDetailEvent();

  @override
  List<Object?> get props => [];
}

class DetailStarted extends CharacterDetailEvent {
  const DetailStarted();
}

class SaveToggled extends CharacterDetailEvent {
  const SaveToggled();
}

class CharacterDetailBloc
    extends Bloc<CharacterDetailEvent, CharacterDetailState> {
  CharacterDetailBloc({
    required this.phone,
    required Character character,
    required this.isCharacterSaved,
    required this.loadCharacterProfile,
    required this.saveCharacter,
    required this.removeSavedCharacter,
  }) : super(CharacterDetailState(character: character)) {
    on<DetailStarted>(_onStarted);
    on<SaveToggled>(_onToggle);
  }

  final String phone;
  final IsCharacterSaved isCharacterSaved;
  final LoadCharacterProfile loadCharacterProfile;
  final SaveCharacter saveCharacter;
  final RemoveSavedCharacter removeSavedCharacter;

  Future<void> _onStarted(
    DetailStarted event,
    Emitter<CharacterDetailState> emit,
  ) async {
    emit(state.copyWith(loadingDetails: true, error: null));
    final savedResult = await isCharacterSaved(
      CharacterRef(phone: phone, id: state.character.id),
    );
    final profileResult = await loadCharacterProfile(
      ProfileParams(phone: phone, character: state.character),
    );
    final saved = savedResult.fold((_) => state.saved, (value) => value);
    profileResult.fold(
      (failure) => emit(
        state.copyWith(
          saved: saved,
          loadingDetails: false,
          error: failure.message,
        ),
      ),
      (character) => emit(
        state.copyWith(
          character: character,
          saved: saved,
          loadingDetails: false,
          error: null,
        ),
      ),
    );
  }

  Future<void> _onToggle(
    SaveToggled event,
    Emitter<CharacterDetailState> emit,
  ) async {
    emit(state.copyWith(saving: true, error: null));
    final result = state.saved
        ? await removeSavedCharacter(
            CharacterRef(phone: phone, id: state.character.id),
          )
        : await saveCharacter(
            SaveCharacterParams(phone: phone, character: state.character),
          );
    result.fold(
      (failure) => emit(state.copyWith(saving: false, error: failure.message)),
      (_) => emit(state.copyWith(saving: false, saved: !state.saved)),
    );
  }
}
