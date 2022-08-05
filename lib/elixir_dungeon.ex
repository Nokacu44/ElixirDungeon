defmodule ElixirDungeon do

  defmodule Creature do
    defstruct name: "Creature", pos: {0,0}, attk: 1, def: 1, hp: 10
  end

  def start(_type,_args) do
    game_state = %{
      player: %Creature{name: "Player", pos: {1,2}, attk: 5, def: 5},
      monsters: (for _n <- 0..5, do: %Creature{name: "Monster", pos: {Enum.random(0..10),Enum.random(0..10)},attk: 1,def: 10}),
    }
    list = Enum.map(game_state[:monsters], fn x -> x.pos end)
    game_state = Map.put(game_state, :monster_position, list)
    print_map game_state
    loop game_state
  end


  defp player_logic(%{player: _player} = state,input) do
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


  defp update(input, state) do
    state =  player_logic(state,input) |> print_map |> turn_events

    state
  end

  defp turn_events(state) do
    %{player: player, monsters: monsters ,monster_position: list} = state
    cond do
      player.pos in list -> Enum.find(monsters, fn x -> x.pos == player.pos end) |> init_battle(state)

      true -> state
    end
  end

  defp init_battle(monster, %{player: player} = state) do
      IO.puts "This is the battle stage"
      IO.puts monster.name
      IO.puts monster.hp
      action = IO.gets "Choose your battle action ->"
      action = action |> String.downcase |> String.trim

      cond do
        action in ["attack","atk"] -> monster = %{monster | hp: monster.hp - 1}
                                      (enemy_turn(state,monster) |> check_end_battle(player,monster,state))
        true -> nil
      end


  end

  defp enemy_turn(%{player: _player} = _state,monster) do
    if monster.hp <= 0 do
      :dead
    else
      IO.puts monster.name <> " attacks player for " <> ( Enum.random(0..10) |> Integer.to_string) <> " points"

      :alive
    end
  end

  defp check_end_battle(monster_status ,player, monster ,state) do
    cond do
      monster_status == :dead -> state
      player.hp <= 0 -> state
      true -> init_battle(monster,state)
    end
  end

  defp move_player_by(%{player: player} = state, {dx,dy}) do
    {x,y} = player.pos
    player = %{player | pos: {x + dx, y + dy}}
    %{state | player: player}
  end

  def loop(state) do
    %{ monsters: monsters} = state
    state = Map.put(state, :monster_position, Enum.map(monsters, fn x -> x.pos end))
    input = IO.gets "Select action ->"
    # recursion
    loop update input,state
  end

  defp print_map(%{player: player, monster_position: list}=state) do
    for y <- 0..10 do
      for x <- 0..10 do
        cond do
          {x,y} in list and {x,y} == player.pos -> IO.write "X"
          {x,y} in list -> IO.write "M"
          {x,y} == player.pos -> IO.write "P"
          true -> IO.write "."
        end
      end
      IO.puts ""
    end

    state
  end

end
