defmodule Taskman.Test.Tasks do
  @user_id 100
  @test_task %Taskman.Tasks{
    name: "test task",
    cost: 10,
    priority: 10,
    time_posted: 10,
    status: 0,
    deadline: 100,
    user_id: @user_id
  }
  @test_category_name_1 "test_category_1"
  @test_category_name_2 "test_category_2"

  use ExUnit.Case

  setup_all do
    Taskman.Stores.Categories.try_create_category(@test_category_name_1, @user_id)
    Taskman.Stores.Categories.try_create_category(@test_category_name_2, @user_id)
    :ok
  end

  # does not delete category table since these are largely static
  # for the purpose of this test
  setup do
    Taskman.Repo.delete_all(Taskman.Tasks)
    Taskman.Repo.delete_all(Taskman.TasksToCategories)
    :ok
  end

  defp verify_task_matches(a, b) do
    assert a.name == b.name
    assert a.cost == b.cost
    assert a.priority == b.priority
    assert a.time_posted == b.time_posted
    assert a.status == b.status
    assert a.deadline == b.deadline
    assert a.user_id == b.user_id
  end

  defp verify_categories_match(a, b) do
    assert Enum.map(a, fn c -> c.category_id end) == Enum.map(b, fn c -> c.category_id end)
    assert Enum.map(a, fn c -> c.category_name end) == Enum.map(b, fn c -> c.category_name end)
  end

  test "store task without categories" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    verify_task_matches(task, @test_task)
  end

  test "store task with categories" do
    categories = Taskman.Stores.Categories.get_categories_for_user(@user_id)

    {:ok, task} =
      Taskman.Stores.Tasks.insert_task(
        @test_task,
        Enum.map(categories, fn c -> c.category_id end)
      )

    verify_task_matches(task, @test_task)
    verify_categories_match(task.categories, categories)

    {:ok, task} = Taskman.Stores.Tasks.get_task_by_id(task.id, task.user_id)
    verify_task_matches(task, @test_task)
    verify_categories_match(task.categories, categories)
  end

  test "cannot find task when getting by id" do
    {:not_found, _resp} = Taskman.Stores.Tasks.get_task_by_id(0, @test_task.user_id)
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    {:ok, _resp} = Taskman.Stores.Tasks.get_task_by_id(task.id, @test_task.user_id)

    # not found because user_id doesn't match
    {:not_found, _resp} = Taskman.Stores.Tasks.get_task_by_id(task.id, @test_task.user_id + 1)

    # not found because task_id doesn't match
    {:not_found, _resp} = Taskman.Stores.Tasks.get_task_by_id(task.id + 1, @test_task.user_id)
  end

  test "set task status" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    {1, _resp} = Taskman.Stores.Tasks.set_status(task.id, task.status + 1, task.user_id)
    {0, _resp} = Taskman.Stores.Tasks.set_status(task.id, task.status + 1, task.user_id + 1)
  end

  test "delete task" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    {1, _resp} = Taskman.Stores.Tasks.delete_task_by_id(task.id, task.user_id)

    # should not delete task because user_id, task_id combo can't find a result
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    {0, _resp} = Taskman.Stores.Tasks.delete_task_by_id(task.id, task.user_id + 1)
  end

  test "get_tasks should filter by status" do
    statuses_to_task_ids =
      Taskman.Logic.Status.get_statuses()
      |> Map.values()
      |> Enum.map(fn s ->
        {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
        {1, _resp} = Taskman.Stores.Tasks.set_status(task.id, s, @user_id)
        {s, task.id}
      end)

    statuses_to_task_ids
    |> Enum.map(fn {s, t_id} ->
      [task] = Taskman.Stores.Tasks.get_tasks(s, @user_id, [])
      assert task.id == t_id
    end)
  end

  test "tasks should be timestamped when completed" do
    {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [])
    assert is_nil(task.time_completed)

    {:ok, num} = Taskman.Logic.Status.to_number_from_string("completed")

    {1, _resp} = Taskman.Stores.Tasks.set_status(task.id, num, @user_id)

    {:ok, task} = Taskman.Stores.Tasks.get_task_by_id(task.id, @user_id)
    assert not is_nil(task.time_completed)
  end

  test "get_tasks should filter by category" do
    category_ids_to_task_ids =
      Taskman.Stores.Categories.get_categories_for_user(@user_id)
      |> Enum.map(fn c ->
        {:ok, task} = Taskman.Stores.Tasks.insert_task(@test_task, [c.category_id])
        {c.category_id, task.id}
      end)

    category_ids_to_task_ids
    |> Enum.map(fn {c_id, t_id} ->
      [task] = Taskman.Stores.Tasks.get_tasks(0, @user_id, [c_id])
      assert task.id == t_id
    end)
  end
end
