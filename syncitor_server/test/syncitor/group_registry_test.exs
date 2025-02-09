defmodule Syncitor.GroupRegistryTest do
  use ExUnit.Case

  setup do
    group_registry_pid = start_supervised!(Syncitor.GroupRegistry)
    %{group_registry_pid: group_registry_pid}
  end

  test "testing group registry stuff", %{group_registry_pid: group_registry_pid} do
    group_server_1 =
      Syncitor.GroupRegistry.get_group_server(group_registry_pid, "test_group_1")

    assert group_server_1 ==
             Syncitor.GroupRegistry.get_group_server(group_registry_pid, "test_group_1")

    assert :ok == Syncitor.GroupServer.join_group(group_registry_pid, "test_group_1", "user_id2")
  end
end
