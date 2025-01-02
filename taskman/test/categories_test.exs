defmodule Taskman.Test.Categories do
  use ExUnit.Case

  @category_name "test"
  @user_id 0

  setup do
    Taskman.Repo.delete_all(Taskman.Categories)
    Taskman.Repo.delete_all(Taskman.Tasks)
    :ok
  end

  test "store category" do
    {:ok, cat} = Taskman.Stores.Categories.try_create_category(@category_name, @user_id)
    assert cat.category_name == @category_name
    assert cat.user_id == @user_id
  end

  test "fail to store category from duplicate name" do
    {:ok, cat} = Taskman.Stores.Categories.try_create_category(@category_name, @user_id)
    assert cat.category_name == @category_name
    assert cat.user_id == @user_id

    {:error, _reason} = Taskman.Stores.Categories.try_create_category(@category_name, @user_id)
  end

  test "get category id" do
    {:ok, cat} = Taskman.Stores.Categories.try_create_category(@category_name, @user_id)
    {:ok, id} = Taskman.Stores.Categories.get_category_id(@category_name, @user_id)

    assert cat.category_id == id
  end

  test "failing to get category id" do
    {:not_found, _reason} = Taskman.Stores.Categories.get_category_id(@category_name, @user_id)
  end

  test "failing to get category id where category does not belong to user" do
    {:ok, _resp} = Taskman.Stores.Categories.try_create_category(@category_name, @user_id)

    {:not_found, _reason} =
      Taskman.Stores.Categories.get_category_id(@category_name, @user_id + 1)
  end
end
