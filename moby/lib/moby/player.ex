defmodule Moby.Player do
  @moduledoc """
  Represents a Love Letter player.
  """

  alias Moby.{Game, Victory}

  defstruct name: "", current_cards: [], played_cards: [], active?: true
  # TODO: include score key in the struct, once many-round play is implemented

  def execute_move(game, :princess) do
    update(game, &lose/2)
  end

  def execute_move(game, played_card) do
    update(game, &play_card/2, played_card)
  end

  def next(game = %Game{deck: []}), do: Victory.round_over(game)

  def next(game) do
    [drawn_card | new_deck] = game.deck

    update(game, &draw_card/2, drawn_card)
    |> Map.put(:deck, new_deck)
    |> Moby.Cards.check_countess()
  end

  defp update(game, function, args \\ nil) do
    updated_player = hd(game.players) |> function.(args)
    new_players = [updated_player] ++ tl(game.players)
    %Game{game | players: new_players}
  end

  defp play_card(player, played_card) do
    player
    |> remove_from_hand(played_card)
    |> add_to_discarded(played_card)
  end

  defp draw_card(player, dealt_card) do
    Map.put(player, :current_cards, player.current_cards ++ [dealt_card])
  end

  defp lose(player, _) do
    Map.put(player, :active?, false)
  end

  defp remove_from_hand(player, card) do
    Map.put(player, :current_cards, player.current_cards |> List.delete(card))
  end

  defp add_to_discarded(player, card) do
    Map.put(player, :played_cards, player.played_cards ++ [card])
  end
end
