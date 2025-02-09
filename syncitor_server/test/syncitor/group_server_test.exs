defmodule Syncitor.GroupServerTest do
  use ExUnit.Case

  setup do
    group_pid = start_supervised!(Syncitor.GroupServer)
    %{group_pid: group_pid}
  end

  test "testing group pid stuff", %{group_pid: group_pid} do
  end
end
