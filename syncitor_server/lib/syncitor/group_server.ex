# this manages commit and merge stuff and calls inMemstore to put into store
defmodule Syncitor.GroupServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # need to init file 
  def init(_opts) do
    {:ok,
     %{in_mem_store: InMemoryStore.Store.new(), tcp_pool: TcpServer.TcpServer.new(), user_ids: []}}
  end

  # think how to handle commits and merges
  # def handle_cast({:merge, Syncitor.Commit}, in_mem_store) do
  # end

  def handle_call({:join_group, user_id}, _from, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    user_ids = [user_id | user_ids]
    {:reply, :ok, %{state | user_ids: user_ids}}
  end

  def handle_call({:get_group_users}, _from, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    {:reply, user_ids, state}
  end

  def handle_cast({:boradcast, commit}, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    {:ok, tcp_pool} = Map.fetch(state, :tcp_pool)
    Enum.map(user_ids, fn uid -> TcpServer.TcpServer.send(tcp_pool, uid, commit) end)
    {:noreply, state}
  end

  # TODO:
  def handle_cast({:commit, commit}, state) do
  end

  def handle_cast({:merge, commit}, state) do
  end

  @doc """
  Interface function called by client to add user into a group
  """
  def join_group(registry_pid, group_id, user_id) do
    server_pid = Syncitor.GroupRegistry.get_group_server(registry_pid, group_id)
    GenServer.call(server_pid, {:join_group, user_id})
  end

  @doc """
  Interface function called by client to gett all users of a group
  """
  def get_all_users(registry_pid, group_id) do
    server_pid = Syncitor.GroupRegistry.get_group_server(registry_pid, group_id)
    GenServer.call(server_pid, {:get_group_users})
  end
end
