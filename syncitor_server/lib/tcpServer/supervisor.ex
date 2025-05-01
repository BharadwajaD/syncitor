# supervise tcpserver
defmodule TcpServer.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg , name: __MODULE__)
  end

  def init(init_arg) do
   children = [
      {TcpServer.TcpServer, init_arg}
    ] 
    
    Supervisor.init(children, strategy: :one_for_one)
  end

end
