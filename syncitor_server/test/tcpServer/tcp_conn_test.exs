defmodule TcpServer.TcpConnTest do
  use ExUnit.Case

  test "testing parse_packet function" do
    packet = "\"1:join:123abc\"\r\n"
    String.trim(packet)
    IO.inspect(packet)
    {:ok, parsed} = Tcp.Packet.parse_packet(packet)

    assert parsed == %Tcp.Packet{command: "JOIN", version: 1, group_id: "123abc"}
  end
end
