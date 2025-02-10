defmodule InMemoryTest.InMemoryTest do
  use ExUnit.Case

  setup do
    store_pid = start_supervised!(InMemoryStore.Store)
    %{store_pid: store_pid}
  end
  
  test "testing in memory stuff", %{store_pid: store_pid} do
    InMemoryStore.Store.put("group_id_test")

    assert InMemoryStore.Store.get("group_id_test") == []
  end

end
