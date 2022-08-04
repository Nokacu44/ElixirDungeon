defmodule ElixirDungeon do

  defmodule Creature do
    defstruct name: "Creature", pos: {0,0}
  end

  def start(_type,_args) do
    game_state = %{
      player: %Creature{name: "Player", pos: {1,2}},
      monsters: (for _n <- 0..5, do: %Creature{name: "Monster", pos: {Enum.random(0..10),Enum.random(0..10)}})
    }

    loop game_state
  end
  def update(input, state) do
    state = player_logic(input,state)
    state
  end

  def turn_events(state) do
    %{player: player, monsters: monsters, monster_position: list} = state
    cond do
      player.pos in list -> state
    end
  end

  def player_logic(input,%{player: player} = state) do
    input = input |> String.downcase |> String.split
    first_command = input |> List.first
    second_command = input |> tl |> List.first
    case first_command do
      "move" -> case second_command do
                  "right" -> s = move_player_by(state,{1,0}); IO.puts(s[:player].pos |> elem(0)); s
                  "left" -> s = move_player_by(state,{-1,0}); IO.puts(s[:player].pos |> elem(0)); s
                  "up" -> s = move_player_by(state,{0,-1}); IO.puts(s[:player].pos |> elem(1)); s
                  "down" -> s = move_player_by(state,{0,1}); IO.puts(s[:player].pos |> elem(1)); s
                  _ -> state
                end

       _ -> state
    end
  end


  def move_player_by(%{player: player} = state, {dx,dy}) do
    {x,y} = player.pos
    player = %{player | pos: {x + dx, y + dy}}
    %{state | player: player}
  end

  def loop(state) do
    %{player: player, monsters: monsters} = state
    list = Enum.map(monsters, fn x -> x.pos end)
    state = Map.put(state, :monster_position, list)
    IO.puts player.name

    for y <- 0..10 do
      for x <- 0..10 do
        cond do
          {x,y} in list -> IO.write "M"
          {x,y} == player.pos -> IO.write "P"
          true -> IO.write "."
        end
      end
      IO.puts ""
    end

    input = IO.gets "Select action ->"

    # recursion
    loop update(input,state)
  end
end
