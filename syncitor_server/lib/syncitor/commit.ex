defmodule Syncitor.Commit do

  defstruct [:command, :location, :to_char, :timestamp]
  @type t :: %__MODULE__{command: String.t(), 
    location: {integer(), integer()},
    to_char: [String.t()],
    timestamp: integer()
  }

  @spec get_location_commits([t()]) :: %{{integer(), integer()} => [t()]}
  @doc """
  will contain commits in stack ( LIFO ) 
  replace are converted to delete, add operation
  """
  def get_location_commits(commits) do

    commits 
    |> Enum.reduce(%{}, fn commit, acc ->  
      %__MODULE__{location: location, command: command} = commit
      acc = Map.put_new(acc, location, [])
      if command == Syncitor.Constants.replace do
        delete_commit = %__MODULE__{commit | command: Syncitor.Constants.delete}
        add_commit = %__MODULE__{commit | command: Syncitor.Constants.add}
        acc = Map.update!(acc, location, fn location_commits -> [ delete_commit | location_commits]  end) 
        Map.update!(acc, location, fn location_commits -> [add_commit | location_commits]  end) 
      else
        Map.update!(acc, location, fn location_commits -> [commit | location_commits]  end)
      end
    end)
    |> Enum.map(fn {location , commit_list} -> {location , Enum.reverse(commit_list)} end)
    |> Enum.into(%{})

  end

  defp merge(commit, stack) when stack == []do
    [commit]
  end

  defp merge(commit, [top | stack]) do
    %__MODULE__{command: top_command} = top
    %__MODULE__{command: curr_command} = commit

    if top_command != curr_command do
      stack
    else
      [commit, top | stack]
    end
  end


  @spec merge([t()]) :: [t()]
  def merge(commits) do
    get_location_commits(commits)
    |> Enum.reduce([], fn {_, commit_list}, acc -> 
      acc ++ commit_list |> Enum.reduce([], fn commit, stack -> merge(commit, stack) end)
    end)
    |> Enum.reverse()
  end
end

