defmodule Utils.Constants do
  def add do
    "ADD"
  end
  def replace do
    "REPLACE"
  end
  def delete do
    "DELETE" end

  @commit "COMMI"
  @join "JOIN"

  def commit, do: @commit
  def join, do: @join
end
