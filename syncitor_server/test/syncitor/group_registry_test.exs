defmodule Syncitor.GroupRegistryTest do
  use ExUnit.Case

  setup_all do
    supervisor_pid = start_supervised!(Syncitor.Supervisor)
    in_mem_pid = start_supervised!(InMemoryStore.Store)
    %{}
  end

  test "testing group creating in registry" do

    assert :ok == Syncitor.GroupServer.create_group_server("test_group_1")
    {:ok, gs_pid} = Syncitor.GroupRegistry.get_group_server(Syncitor.GroupRegistry, "test_group_1")

  end

  test "group registry should not crash even if a group server crashes" do

    assert :ok == Syncitor.GroupServer.create_group_server("test_crash_group")
    {:ok, gs_pid} = Syncitor.GroupRegistry.get_group_server(Syncitor.GroupRegistry, "test_crash_group")
    GenServer.stop(gs_pid, :bad_input)
    :timer.sleep(100) #give some time for the group_server to update its pid in registry
    {:ok, ngs_pid } = Syncitor.GroupRegistry.get_group_server(Syncitor.GroupRegistry, "test_crash_group")

    assert gs_pid != ngs_pid
  end
end
