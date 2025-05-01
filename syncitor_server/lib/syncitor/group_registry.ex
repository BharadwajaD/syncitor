defmodule Syncitor.GroupRegistry do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: Syncitor.GroupRegistry)
  end

  def init(_opts) do
    {:ok, Map.new()}
  end


  def handle_call({:get_group_server, group_id}, _from, registry_map) do
      case Map.fetch(registry_map, group_id) do
        {:ok, group_server} ->
          {:reply, {:ok, group_server}, registry_map}

        :error ->
          {:reply, {:error, "group_server not_created/crashed"}, registry_map}
      end

  end

  def handle_call({:put_group_server, group_id, group_pid}, _from, registry_map) do
    registry_map = Map.put(registry_map, group_id, group_pid)
    {:reply, :ok, registry_map}
  end

  def get_group_server(group_id) do
    GenServer.call(Syncitor.GroupRegistry, {:get_group_server, group_id})
  end
end
