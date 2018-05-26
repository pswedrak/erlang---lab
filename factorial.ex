defmodule Factorial do
  @moduledoc false
  def factorial(0) do 1 end
  def factorial(n) do factorial(n-1)*n end

end
