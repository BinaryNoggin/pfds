defmodule Q.Test do
  use ExUnit.Case, async: true
  use PropCheck

  def queue() do
    let terms <- list(integer()) do
      Enum.reduce(terms, Q.empty(), fn term, sub ->
        Q.snoc(sub, term)
      end)
    end
  end

  property "q invariants" do
    forall q <- queue() do
      invariants(q)
    end
  end

  def invariants(%{f: [], r: []}), do: true
  def invariants(%{f: f}) do
    not Enum.empty?(f)
  end

  property "elements are added to the end of the queue" do
    forall {q, term} <- {queue(), term()} do
        q = Q.snoc(q, term)
        term_is_on_the_end(q, term)
    end
  end

  def term_is_on_the_end(q, term) do
    {:ok, tail} = Q.tail(q)
    {:ok, head} = Q.head(q)
    term_is_on_the_end(tail, term, head)
  end

  def term_is_on_the_end(q, term, last_head) do
    case Q.tail(q) do
      {:ok, tail} ->
        {:ok, head} = Q.head(q)
        term_is_on_the_end(tail, term, head)

      {:error, :empty} ->
        last_head == term
    end
  end

  property "q is empty only when all elements have been removed" do
    forall q <- queue() do
      only_empty_when_all_elements_removed(q)
    end
  end

  def only_empty_when_all_elements_removed(q) do
    case Q.tail(q) do
      {:ok, tail} ->
        not Q.empty?(q) && only_empty_when_all_elements_removed(tail)

      {:error, :empty} ->
        Q.empty?(q)
    end
  end

  property "the length of a q is the same as the number of terms in the queue" do
    forall q <- queue() do
      queue_length_same_as_terms_remaining(q)
    end
  end

  def queue_length_same_as_terms_remaining(q) do
    case Q.tail(q) do
      {:ok, tail} ->
        Q.length(q) == Q.length(tail) + 1 && queue_length_same_as_terms_remaining(tail)

      {:error, :empty} ->
        Q.length(q) == 0
    end
  end
end
