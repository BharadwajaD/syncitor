defmodule Syncitor.GroupServer do
  @moduledoc """
  Entry Point of a Group
  """
  use GenServer


  @spec create_group_server(String.t()) :: :ok
  def create_group_server(group_id) do
    {:ok, _pid} = DynamicSupervisor.start_child(Syncitor.GroupServerSupervisor, 
      %{ 
        id: Syncitor.GroupServer,
        start: {Syncitor.GroupServer, :start_link, [%{group_id: group_id}]}
      })
    :ok
  end

  def start_link(args) do
    group_id = Map.get(args, :group_id)
    {:ok, group_pid} = GenServer.start_link(__MODULE__, args)
    # subscribe to registry
    :ok = GenServer.call(Syncitor.GroupRegistry, {:put_group_server, group_id, group_pid}) 
    {:ok , group_pid}
  end

  @type state :: %{
    group_id: %{},
    # in_mem_store: pid(),
    tcp_pool: any(),
    user_ids: [String.t()]
  }
  def init(args) do
    group_id = Map.get(args, :group_id)
    :ok = InMemoryStore.Store.put(group_id)
    {:ok, 
      %{
        group_id: group_id,
        # in_mem_store: InMemoryStore.Store.start_link(),
        tcp_pool: TcpServer.TcpServer.new(),
        user_ids: []}
    }
  end

  def handle_call({:join_group, user_id}, _from, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    user_ids = [user_id | user_ids]
    {:reply, :ok, %{state | user_ids: user_ids}}
  end

  def handle_call({:get_group_users}, _from, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    {:reply, user_ids, state}
  end

  def handle_cast({:broadcast, commit}, state) do
    {:ok, user_ids} = Map.fetch(state, :user_ids)
    {:ok, tcp_pool} = Map.fetch(state, :tcp_pool)
    Enum.map(user_ids, fn uid -> TcpServer.TcpServer.send(tcp_pool, uid, commit) end)
    {:noreply, state}
  end


  # TODO: more better
  defp is_valid_timestamp?(curr_commit, head_commit) do
    %Syncitor.Commit{timestamp: max_timestamp} = head_commit
    %Syncitor.Commit{timestamp: curr_timestamp} = curr_commit
    if curr_timestamp < max_timestamp do
      false
    else
      true
    end
  end

  # TODO:
  # How do you store in InMemoryStore ? 
  # Logic for handling commit and stuff
  def handle_cast({:commit, commit}, state) do 

    %{group_id: group_id, user_ids: user_ids, tcp_pool: tcp_pool} = state
    commits = InMemoryStore.Store.get(group_id)
    [head | _ ] = commits

    if is_valid_timestamp?(commit, head) do
      InMemoryStore.Store.put(group_id, commits ++ [commit])
    end

    # send this to all users
    Enum.map(user_ids, fn uid -> TcpServer.TcpServer.send(tcp_pool, uid, commit) end)
    {:noreply, state}
  end

  def handle_call({:merge, commit}, _from, state) do
  end

  def handle_info({:DOWN, reason, _type, _pid}, state) do
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

  @doc """
  Interface function called by client to submit a commit
  """
  @spec submit_commit(pid(), String.t(), Syncitor.Commit.t()) :: :ok
  def submit_commit(registry_pid, group_id, commit) do 
    server_pid = Syncitor.GroupRegistry.get_group_server(registry_pid, group_id)
    GenServer.cast(server_pid, {:commit, commit})
  end
end
