// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct TodoNews {
    string text;
    bool completed;
}

contract Todos {
    //定义了一个结构体
    struct Todo {
        string text;
        bool completed;
    }

    //这是一个动态数组 todos，用于存储 Todo 结构体。public 修饰符表示 Solidity 会为 todos 数组生成一个自动的 getter 函数，允许外部用户访问。
    Todo[] public todos;


    //create 函数用于创建新的任务，并将任务添加到 todos 数组中。
    //_text 是任务的描述。
    function create(string calldata _text) public {
        // 3 ways to initialize a struct
        // 函数调用方式：直接通过类似函数调用的方式创建并初始化结构体。
        todos.push(Todo(_text, false));

        // 键值对方式：使用键值对形式创建并初始化结构体。
        todos.push(Todo({text: _text, completed: false}));

        // 空结构体初始化方式：首先创建一个空的 Todo 结构体，然后逐个设置属性。
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false

        todos.push(todo);
    }

    //get 函数用于根据索引 index 查询某个任务的详细信息。
    //返回值：返回任务的描述 text 和是否完成 completed。
    //虽然 Solidity 已经为 todos 数组自动生成了一个 getter 函数，但这个 get 函数展示了如何手动读取和返回 struct 的字段。
    //storage vs memory：使用 storage 关键字表示 todo 是对存储在区块链上的实际数据的引用，而不是副本。
    function get(uint256 _index) public view returns (string memory text, bool completed){
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    //功能：updateText 函数允许更新指定任务的描述（text）。
    //参数：_index 是任务在数组中的索引，_text 是要更新的任务描述。
    function updateText(uint256 _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    //功能：toggleCompleted 函数用于切换指定任务的完成状态（completed）。如果任务当前未完成，调用后将其标记为完成；如果已经完成，调用后将其标记为未完成。
    //操作：使用 !todo.completed 取反操作，切换布尔值。
    function toggleCompleted(uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }

    /*
    总结
    这个合约是一个简单的任务管理系统，允许用户执行以下操作：

    创建任务：通过 create 函数向 todos 数组添加新任务，并且可以使用三种不同的方式初始化任务。
    读取任务信息：通过 get 函数根据索引返回任务的描述和完成状态。
    更新任务描述：通过 updateText 函数修改任务的文本内容。
    切换任务完成状态：通过 toggleCompleted 函数将任务的完成状态切换（完成与未完成之间切换）。
    */




}