defmodule Syncitor.Commit do

  defstruct [:command, :location, :chars, :timestamp]
  @type t :: %__MODULE__{command: String.t(), 
    location: {integer(), integer()},
    chars: [String.t()],
    timestamp: integer()
  }

  @spec merge(t()) :: :ok
  def merge(%__MODULE__{command: command, location: location, chars: chars, timestamp: timestamp}) do
    :ok
  end
  
  #TODO: commit and merge functions
end
