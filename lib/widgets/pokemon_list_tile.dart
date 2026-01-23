import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_state_management/models/pokemon.dart';
import 'package:riverpod_state_management/providers/pokemon_data_providers.dart';
import 'package:riverpod_state_management/widgets/pokemon_stats_card.dart'
    show PokemonStatsCard;
import 'package:skeletonizer/skeletonizer.dart';

class PokemonListTile extends ConsumerWidget {
  final String pokemonURL;

  late FavoritePokemonsProvider _favoritePokemonsProvider;
  late List<String> _favoritePokemons;

  PokemonListTile({super.key, required this.pokemonURL});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _favoritePokemonsProvider = ref.watch(favoritePokemonsProvider.notifier);
    _favoritePokemons = ref.watch(favoritePokemonsProvider);
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));

    return pokemon.when(
      data: (data) {
        return _tile(context, false, data);
      },
      error: (error, stackTrace) {
        return Text('error $error');
      },
      loading: () {
        return _tile(context, true, null);
      },
    );
  }

  Widget _tile(BuildContext context, bool isLoading, Pokemon? pokemon) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () {
          if (!isLoading) {
            showDialog(
              context: context,
              builder: (_) {
                return PokemonStatsCard(pokemonURL: pokemonURL);
              },
            );
          }
        },
        child: ListTile(
          leading: pokemon != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(pokemon.sprites!.frontDefault!),
                )
              : CircleAvatar(),
          title: Text(
            pokemon != null
                ? pokemon.name!.toUpperCase()
                : "Currently loading name for Pokemon.",
          ),
          subtitle: Text(
            "Has ${pokemon?.moves?.length?.toString() ?? "0"} moves",
          ),
          trailing: IconButton(
            onPressed: () {
              if (_favoritePokemons.contains(pokemonURL)) {
                _favoritePokemonsProvider.removeFavoritePokemon(pokemonURL);
              } else {
                _favoritePokemonsProvider.addFavoritePokemon(pokemonURL);
              }
            },
            icon: Icon(
              _favoritePokemons.contains(pokemonURL)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
