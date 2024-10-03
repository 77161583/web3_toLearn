// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
合约 X：
X 有一个公开的状态变量 name（字符串类型），并且带有构造函数，用于初始化 name 变量。
构造函数接受一个字符串参数 _name，将其赋值给状态变量 name。
合约 Y：
Y 与 X 类似，定义了一个公开的状态变量 text，并且构造函数接受一个字符串参数 _text，用于初始化 text 变量。
*/
// Base contract X
contract X {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

// Base contract Y
contract Y {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

//在继承列表中传递参数
/*
功能：合约 B 继承自 X 和 Y，并且在继承列表中直接给父合约的构造函数传递参数。
X("Input to X")：调用合约 X 的构造函数，并传入 "Input to X" 作为参数，初始化 name。
Y("Input to Y")：调用合约 Y 的构造函数，并传入 "Input to Y" 作为参数，初始化 text。
特点：在继承列表中直接传递参数给父合约的构造函数时，不需要定义子合约的构造函数。继承关系中父合约的构造函数会自动被调用。
*/
contract B is X("Input to X"), Y("Input to Y") {}


/*
功能：合约 C 继承自 X 和 Y，并且在合约 C 的构造函数中显式传递参数给父合约的构造函数。
在构造函数 C 中传入 _name 和 _text，并通过 X(_name) 和 Y(_text) 分别调用父合约 X 和 Y 的构造函数。
子合约 C 的构造函数允许外部调用时动态传递参数，而不像合约 B 那样在继承时就已经固定了参数。
特点：这种方式使得在部署合约时可以动态传递参数，更加灵活。
*/
contract C is X, Y {
    constructor(string memory _name, string memory _text) X(_name) Y(_text) {}
}


/*
功能：合约 D 继承自 X 和 Y，并且在构造函数中为父合约 X 和 Y 传递参数。
调用顺序：
即使 X 和 Y 在构造函数中以特定顺序调用，父合约的构造函数总是根据继承顺序调用。因此，X 构造函数会在 Y 构造函数之前被调用。
构造函数内部的调用顺序不会影响父合约的构造函数执行顺序。    
*/
contract D is X, Y {
    constructor() X("X was called") Y("Y was called") {}
}

/*
功能：合约 E 的构造函数中首先调用了 Y 的构造函数，然后调用了 X 的构造函数。
调用顺序：
虽然在构造函数中 Y 被先调用，但父合约构造函数的执行顺序依然是根据继承顺序进行的：X 的构造函数先被调用，接着是 Y 的构造函数。
这说明即使在构造函数中定义了父合约构造函数的调用顺序，实际执行的顺序仍然根据继承顺序来决定。
*/
contract E is X, Y {
    constructor() Y("Y was called") X("X was called") {}
}

/*
总结：
父合约的构造函数调用：
父合约的构造函数可以通过两种方式传递参数：在继承列表中传递，或者在子合约的构造函数中传递。
在继承列表中传递参数时，父合约构造函数会自动被调用。
在构造函数中传递参数时，合约的调用更灵活，可以动态传入参数。
构造函数的执行顺序：
无论在子合约的构造函数中如何调用父合约的构造函数，父合约的构造函数总是按照继承顺序被执行。

总结：
简单、固定参数：使用继承列表传递参数。 B
复杂、动态参数：使用构造函数传递参数。 C
*/

