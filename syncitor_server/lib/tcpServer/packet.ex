defmodule Tcp.Packet do
  defstruct version: 1 , command: "", group_id: "", commit: %Syncitor.Commit{}
  @type t :: %__MODULE__{
    version: integer,
    command: String.t(), 
    group_id: String.t(), 
    commit: Syncitor.Commit.t(),
  }

  # "\"1:JOIN:123abc\"\r\n"
  # to {version: 1, command: "JOIN", group_id: "123abc"}
  # "\"1:COMMIT:123abc:add:row:col:a\"\r\n"
  # to {version: 1, command: "COMMIT", group_id: "123abc", commit: {command: add, location: {row, col}, to_char: a}}
  @spec parse_packet(String.t()):: {:ok, Tcp.Packet.t()}
  def parse_packet(packet) do
    splits = packet
    |> String.trim()                
    |> String.trim_leading("\"")    
    |> String.trim_trailing("\"")   
    |> String.split(":")            
    |> Enum.map(&String.trim(&1))   

    parse_packet_splits(splits)
  end

  # handling error
  defp parse_packet_splits(splits) when length(splits) < 3 do
    {:error, "bad request"}
  end

  defp parse_packet_splits([version, req_command, group_id | _]) when req_command == "JOIN" do
    {:ok, %Tcp.Packet{version: String.to_integer(version), command: req_command, group_id: group_id}}
  end

  defp parse_packet_splits([version, req_command, group_id | payload]) when req_command == "COMMIT" do
    [command, row, col, to_char] = payload
    {
      :ok, %Tcp.Packet{
        version: String.to_integer(version), command: req_command, group_id: group_id,
        commit: %Syncitor.Commit{
          command: command,
          location: %{row: String.to_integer(row), col: String.to_integer(col)},
          to_char: to_char
        }
      }
    }
  end

end
