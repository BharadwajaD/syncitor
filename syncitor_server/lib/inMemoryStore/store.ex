defmodule InMemoryStore.Store do
  @moduledoc """
  KeyValue store
  Make it as seperate layer and scale if needed
  """
  use Agent

  @type t()::pid()

  def start_link(_opts) do
    Agent.start_link(fn  -> %{} end, name: __MODULE__)
  end

  @spec put(String.t(), [Syncitor.Commit.t()]) :: :ok
  def put(key, value \\ []) do
    Agent.update(__MODULE__,  &Map.put(&1, key, value))
  end

  @spec get(String.t()) :: [Syncitor.Commit.t()]
  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
