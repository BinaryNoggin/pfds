defmodule Queue do
  @moduledoc """
  Documentation for Queue.
  """

  def empty, do: {[], []}

  def empty?({[], []}), do: true
  def empty?(_), do: false

  def snoc({f, r}, x), do: checkf(f, [x | r])

  def head({[], _}), do: {:error, :empty}
  def head({[h | _], _}), do: {:ok, h}

  def tail({[], _}), do: {:error, :empty}
  def tail({[_ | f], r}), do: {:ok, checkf(f, r)}

  defp checkf([], r), do: {Enum.reverse(r), []}
  defp checkf(f, r), do: {f, r}
end
