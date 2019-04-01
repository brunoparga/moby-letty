defmodule Moby.Action do
  @moduledoc """
  Functions that update the game with the running of a given action by a player.
  This is only default actions like drawing and discarding; specialized actions
  are dealt with by the character modules in the characters directory.
  """

  alias Moby.{GameState, Player}

  @type mfargs() :: {module(), atom(), [atom]}

  @doc """
  Run the given action on the current player. Return a game.
  """
  @spec execute_current(GameState.t(), mfargs()) :: GameState.t()
  def execute_current(game, mfa) do
    execute(game, hd(game.players).name, mfa)
  end

  @doc """
  Run the given action on the given player. Return a game.
  """
  # TODO: DO SOMETHING ABOUT THIS TAKING A NAME OR A PLAYER STRUCT
  @spec execute(GameState.t(), String.t(), mfargs()) :: GameState.t()
  def execute(game, player_name, mfa) do
    players = new_players(player_name, game.players, mfa)
    %GameState{game | players: players}
  end

  @spec new_players(String.t(), [Player.t()], {module(), atom(), [atom]}) :: [Player.t()]
  defp new_players(player_name, players, mfa) do
    Enum.map(players, fn player ->
      if player.name == player_name, do: new_player(player, mfa), else: player
    end)
  end

  defp new_player(player, {module, function, args}) do
    apply(module, function, [player] ++ args)
  end

  # Card-playing actions

  @spec play_card(Player.t(), atom) :: Player.t()
  def play_card(player, played_card) do
    player =
      player
      |> remove_from_hand(played_card)
      |> add_to_discarded(played_card)

    if played_card == :princess, do: lose(player), else: player
  end

  @spec draw_card(Player.t(), atom) :: Player.t()
  def draw_card(player, drawn_card) do
    Map.put(player, :current_cards, player.current_cards ++ [drawn_card])
  end

  @spec lose(Player.t()) :: Player.t()
  def lose(player) do
    Map.put(player, :active?, false)
  end

  @spec remove_from_hand(Player.t(), atom) :: Player.t()
  defp remove_from_hand(player, card) do
    Map.put(player, :current_cards, player.current_cards |> List.delete(card))
  end

  @spec add_to_discarded(Player.t(), atom) :: Player.t()
  defp add_to_discarded(player, card) do
    Map.put(player, :played_cards, player.played_cards ++ [card])
  end
end
