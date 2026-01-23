import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_state_management/models/page_data.dart';
import 'package:riverpod_state_management/models/pokemon.dart';
import 'package:riverpod_state_management/services/http_services.dart';

class HomePageController extends StateNotifier<HomePageData> {
  final GetIt _getIt = GetIt.instance;

  late HttpServices _httpService;

  HomePageController(super._state) {
    _httpService = _getIt<HttpServices>();
    _setup();
  }

  Future<void> _setup() async {
    loadData();
  }

  Future<void> loadData() async {
    if (state.data == null) {
      Response? res = await _httpService.get(
        "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0",
      );
      if (res != null && res.data != null) {
        PokemonListData data = PokemonListData.fromJson(res.data);
        state = state.copyWith(data: data);
        print(state.data?.results?.first);
      }
    } else {
      if (state.data?.next != null) {
        Response? res = await _httpService.get(state.data!.next!);

        if (res != null && res.data != null) {
          PokemonListData data = PokemonListData.fromJson(res.data!);
          state = state.copyWith(
            data: data.copyWith(
              results: [
                ...?state.data?.results,
                 ...?data.results
                ],
            ),
          );
        }
      }
    }
  }
}
