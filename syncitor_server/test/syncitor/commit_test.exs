defmodule Syncitor.CommitTest do
  use ExUnit.Case

  setup do
    %{
      commits: [
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,0}, to_char: "a", timestamp: 1},
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,1}, to_char: "b", timestamp: 2},
        %Syncitor.Commit{command: Syncitor.Constants.delete, location: {0,1}, timestamp: 3},
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "d", timestamp: 4},
        %Syncitor.Commit{command: Syncitor.Constants.replace, location: {0,3}, to_char: "e", timestamp: 5},
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "f", timestamp: 6},
      ]
    }
  end

  test "get location commits test" , %{commits: commits} do
    expected_location_commit_map = %{
      {0,0} => [
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,0}, to_char: "a", timestamp: 1},
      ],
      {0,1} => [
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,1}, to_char: "b", timestamp: 2},
        %Syncitor.Commit{command: Syncitor.Constants.delete, location: {0,1}, timestamp: 3},
      ],
      {0,3} => [
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "d", timestamp: 4},
        %Syncitor.Commit{command: Syncitor.Constants.delete, location: {0,3}, to_char: "e", timestamp: 5},
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "e", timestamp: 5},
        %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "f", timestamp: 6},
      ],
    }

    assert expected_location_commit_map == Syncitor.Commit.get_location_commits(commits)
  end
  
  test "basic commit merge test" , %{commits: commits} do
    expected_commits = [
      %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,0}, to_char: "a", timestamp: 1},
      %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "e", timestamp: 5},
      %Syncitor.Commit{command: Syncitor.Constants.add, location: {0,3}, to_char: "f", timestamp: 6},
    ]
    assert expected_commits == Syncitor.Commit.merge(commits)
  end
end
