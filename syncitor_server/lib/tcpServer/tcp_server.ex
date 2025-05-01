defmodule TcpServer.TcpServer do
  alias TcpServer.TcpConn
  use GenServer
  require Logger

  defmodule TcpServer.State do
    defstruct [:port, :socket]
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: TcpServer)
  end

  def init(init_arg) do
    port = Keyword.get(init_arg, :port,42069)
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Listening on port: #{port}")
    {:ok, %TcpServer.State{port: port, socket: socket}}
  end

  def handle_call({:accept}, _from, state) do
    %TcpServer.State{socket: socket} = state
    {:ok, conn} = :gen_tcp.accept(socket)
    {:ok, conn_pid} = TcpConn.start_link(conn)
    :ok = :gen_tcp.controlling_process(conn, conn_pid)
    #TODO: handle failures here..
    TcpConn.handle_conn(conn_pid)
    {:reply,:ok,  state}
  end

  # should not be cast, bcoz this function will be keeping on sending messages to the process
  def start_server() do
    Logger.info("Started server")
    GenServer.call(TcpServer, {:accept}, :infinity)
    start_server()
  end

end
