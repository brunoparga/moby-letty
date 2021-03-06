defmodule Moby.Baron do
  alias Moby.{Action, GameState, Victory}

  @spec play(GameState.t()) :: GameState.t()
  def play(game) do
    [hd(game.players), game.target_player]
    |> Enum.map(&Victory.score_card/1)
    |> compare(game)
  end

  @spec compare([{Moby.Player.t(), pos_integer()}], GameState.t()) :: GameState.t()
  defp compare([{_self, self_score} | [{target, target_score}]], game) do
    cond do
      self_score > target_score ->
        Action.execute(game, target.name, {Action, :lose, []})

      self_score < target_score ->
        Action.execute_current(game, {Action, :lose, []})

      self_score == target_score ->
        game
    end
  end
end
