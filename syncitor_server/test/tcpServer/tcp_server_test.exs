defmodule TcpServer.TcpServerTest do
  use ExUnit.Case

  setup_all do
    server_pid = start_supervised!({TcpServer.Supervisor, [port: 6666]})
    Task.async(fn  ->  TcpServer.TcpServer.start_server() end)
    :timer.sleep(1000)
    {:ok, client} = :gen_tcp.connect('localhost', 6666, [:binary, packet: :raw, active: false])
    %{client: client}
  end

  test "connection to a server test", %{client: client} do
  end

end
