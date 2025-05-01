defmodule Syncitor.GroupServerSupervisor do
  use DynamicSupervisor

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: Syncitor.GroupServerSupervisor)
  end

  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Syncitor.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  def init(init_arg) do
    children = [
      {Syncitor.GroupRegistry, init_arg},
      {Syncitor.GroupServerSupervisor, init_arg},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  
end
