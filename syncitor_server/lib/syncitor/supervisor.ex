defmodule Syncitor.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: Syncitor.GroupServerSupervisor)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Syncitor.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Syncitor.GroupRegistry, name: Syncitor.GroupRegistrySupervisor},
      {Syncitor.DynamicSupervisor, :ok},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  
end
