defmodule Syncitor.GroupServerTest do
  use ExUnit.Case

  setup do
    args = %{group_name: "test_group"}
    in_mem_pid = start_supervised!(InMemoryStore.Store)
    group_pid = start_supervised!({Syncitor.GroupServer, args})
    %{group_pid: group_pid}
  end

  test "testing group pid stuff", %{group_pid: group_pid} do
  end
end
