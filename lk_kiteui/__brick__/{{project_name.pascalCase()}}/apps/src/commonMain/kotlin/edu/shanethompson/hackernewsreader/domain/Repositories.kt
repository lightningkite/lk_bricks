package edu.shanethompson.hackernewsreader.domain

interface BasicRepository<ID, T : HasId<ID>> {
    suspend fun create(item: T): T
    suspend fun update(id: ID, item: T): T
    suspend fun get(): List<T>
    suspend fun detail(id: ID) : T
    suspend fun delete(id: ID): T
}

interface HasId<T> {
    val id: T
}

abstract class BasicMemoryRepository<ID, T> : BasicRepository<ID, T> where T : HasId<ID> {
    protected val items = mutableListOf<T>()

    override suspend fun create(item: T): T {
        items.add(item)
        return item
    }

    protected val itemIndex: (ID) -> Int = { itemId -> items.indexOfFirst { itemId == it.id } }

    override suspend fun update(id: ID, item: T): T {
        items[itemIndex(id)] = item
        return item
    }

    override suspend fun get(): List<T> {
        return items.toList()
    }

    override suspend fun detail(id: ID): T {
        return items[itemIndex(id)]
    }

    override suspend fun delete(id: ID): T {
        return items.removeAt(itemIndex(id))
    }
}

interface TasksRepository : BasicRepository<Long, TodoTask> {
    suspend fun toggleCompleted(id: Long): TodoTask
}

class MockTasksRepo : TasksRepository, BasicMemoryRepository<Long, TodoTask>() {
    override suspend fun toggleCompleted(id: Long): TodoTask {
        val task = items[itemIndex(id)]
        val completedTask = task.copy(completed = !task.completed)
        items[itemIndex(id)] = completedTask
        return completedTask
    }
}

