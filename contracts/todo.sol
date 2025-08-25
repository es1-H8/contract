// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Add a todo

// Edit a todo

// Mark as complete/incomplete

// Delete a todo

// Filter by status (all/completed/pending)

// Persist data (optional: localStorage, backend, or DB)
enum TodoStatus {
    Pending,
    Completed
}
enum TodoFilter {
    All,
    Pending,
    Completed
}

struct TodoStruct {
    uint8 id;
    string title;
    TodoStatus status;
}

contract Todo {
    TodoStruct[] todoList;
    uint8 private nextId = 1;

    function getAllTodos() external view returns (TodoStruct[] memory) {
        return todoList;
    }

    function addTodo(string memory title) external {
        todoList.push(TodoStruct(nextId, title, TodoStatus.Pending));
        nextId++;
    }

    function deleteTodo(uint8 index) external  {
        require(index < todoList.length, "Index out of bounds");
        todoList[index] = todoList[todoList.length - 1];
        todoList.pop();
    }

    function EditTodo(string memory title, uint8 index) external {
        require(index < todoList.length, "Index out of bounds");
        todoList[index].title = title;
    }

    function markTodo(uint8 index, TodoStatus status) external {
        require(index < todoList.length, "Index out of bounds");
        todoList[index].status = status;
    }

    function filterByStatus(TodoFilter filter) external view returns (TodoStruct[] memory) {
        uint count = 0;
        for (uint i = 0; i < todoList.length; i++) {
            if (filter == TodoFilter.All || 
                (filter == TodoFilter.Pending && todoList[i].status == TodoStatus.Pending) ||
                (filter == TodoFilter.Completed && todoList[i].status == TodoStatus.Completed)) {
                count++;
            }
        }

        TodoStruct[] memory filteredTodos = new TodoStruct[](count);
        uint currentIndex = 0;

        for (uint i = 0; i < todoList.length; i++) {
            if (filter == TodoFilter.All || 
                (filter == TodoFilter.Pending && todoList[i].status == TodoStatus.Pending) ||
                (filter == TodoFilter.Completed && todoList[i].status == TodoStatus.Completed)) {
                filteredTodos[currentIndex] = todoList[i];
                currentIndex++;
            }
        }

        return filteredTodos;
    }
}