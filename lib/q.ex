defmodule Q do
  defstruct f: [], r: []

  def empty, do: %__MODULE__{}

  def empty?(%Q{f: []}), do: true
  def empty?(_), do: false

  def snoc(%Q{f: f, r: r}, item) do
    checkf f, [item | r]
  end

  def head(%Q{f: []}), do: {:error, :empty}
  def head(%Q{f: [x | _]}), do: {:ok, x}

  def tail(%Q{f: []}), do: {:error, :empty}
  def tail(%Q{f: [_ | f], r: r}), do: {:ok, checkf(f, r)}

  def length(%Q{f: f, r: r}), do: Kernel.length(f) + Kernel.length(r)

  defp checkf([], r), do: %Q{f: Enum.reverse(r), r: []}
  defp checkf(f, r), do: %Q{f: f, r: r}
end
