defmodule TcpServer.TcpConnTest do
  use ExUnit.Case

  # "\"1:JOIN:123abc\"\r\n"
  # to {version: 1, command: "JOIN", group_id: "123abc"}
  # "\"1:COMMIT:123abc:add:row:col:a\"\r\n"
  # to {version: 1, command: "COMMIT", group_id: "123abc", commit: {command: add, location: {row, col}, to_char: a}}

  test "testing parse_packet function for join req" do
    packet = "\"1:JOIN:123abc\"\r\n"
    {:ok, parsed} = Tcp.Packet.parse_packet(packet)

    assert parsed == %Tcp.Packet{command: "JOIN", version: 1, group_id: "123abc"}
  end

  test "testing parse_packet function for commit req" do
    packet ="\"1:COMMIT:123abc:add:2:4:a\"\r\n"
    {:ok, parsed} = Tcp.Packet.parse_packet(packet)

    assert parsed == %Tcp.Packet{version: 1, command: "COMMIT", group_id: "123abc", 
      commit: %Syncitor.Commit{command: "add", location: %{row: 2, col: 4}, to_char: "a"}}
  end
end
