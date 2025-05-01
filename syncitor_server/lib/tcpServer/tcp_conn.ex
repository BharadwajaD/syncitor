defmodule TcpServer.TcpConn do
  use GenServer
  require Logger
  
  defmodule TcpConn.State do
    defstruct [:conn, :buffer_len]
  end
   
  def start_link(conn) do
     GenServer.start_link(__MODULE__, conn)
  end

  def init(conn) do
    {:ok, %TcpConn.State{conn: conn, buffer_len: 1024}}
  end

  def handle_cast({:handle_conn}, state) do
    %TcpConn.State{conn: conn, buffer_len: buffer_len} = state
    Task.start_link(fn  -> 
      handler(conn, buffer_len)
    end)
    {:noreply, state}
  end

  defp handler(conn, buffer_len) do
    {:ok, packet} = :gen_tcp.recv(conn, 0) #strange: buffer_len: 1024 is giving error
    {:ok, %Tcp.Packet{command: command, group_id: group_id, commit: commit}} = Tcp.Packet.parse_packet(packet)
    case command do
      "COMMIT" -> Syncitor.GroupServer.submit_commit(group_id, commit)
      "JOIN" -> Syncitor.GroupServer.join_group(group_id, conn)
    end

    handler(conn, buffer_len)
  end
   
  def handle_conn(pid) do
    GenServer.cast(pid, {:handle_conn})
  end

end
