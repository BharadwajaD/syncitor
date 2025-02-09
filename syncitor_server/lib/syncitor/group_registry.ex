defmodule Syncitor.GroupRegistry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_opts) do
    {:ok, Map.new()}
  end

  def handle_call({:get_group_server, group_id}, _from, registry_map) do
    {group_server, registry_map} =
      case Map.fetch(registry_map, group_id) do
        {:ok, group_server} ->
          {group_server, registry_map}

        :error ->
          (fn ->
             {:ok, group_server} = Syncitor.GroupServer.start_link([])
             registry_map = Map.put(registry_map, group_id, group_server)
             {group_server, registry_map}
           end).()
      end

    {:reply, group_server, registry_map}
  end

  # OPTIMIZE: introduce put_group_server if needed
  def get_group_server(registry_pid, group_id) do
    GenServer.call(registry_pid, {:get_group_server, group_id})
  end
end
