defmodule Syncitor.GroupServerTest do
  use ExUnit.Case

  setup do
    args = %{group_name: "test_group"}
    group_pid = start_supervised!({Syncitor.GroupServer, args})
    %{group_pid: group_pid}
  end

  test "testing group pid stuff", %{group_pid: group_pid} do
  end
end
