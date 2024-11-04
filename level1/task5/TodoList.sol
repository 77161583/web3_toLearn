// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Demo {
    struct Todo {
        string name;
        bool isCompleted;
    }

    Todo[] public list;

    function create(string memory _name) external {
        list.push(
            Todo({
                name:_name,
                isCompleted:false
            })
        );
    }

    
}