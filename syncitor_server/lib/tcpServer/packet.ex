defmodule Tcp.Packet do
  defstruct version: 1 , command: "", group_id: "", commit: %Syncitor.Commit{}
  @type t :: %__MODULE__{
    version: integer,
    command: String.t(), 
    group_id: String.t(), 
    commit: Syncitor.Commit.t(),
  }

  # "\"1:join:123abc\"\r\n"
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
  defp parse_packet_splits(splits) when length(splits) >= 3 do
    [version, command, group_id | _] = splits
    version = String.to_integer(version)

    command = String.upcase(command)
    {:ok, %Tcp.Packet{version: version, command: command, group_id: group_id}}
  end

end
