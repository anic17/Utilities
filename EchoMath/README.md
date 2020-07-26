# EchoMath

### What is EchoMath?

EchoMath is a program that allows you to perform signed arithmethic operations from your command prompt directly with an `echo`.

### How to use it?

Use it with the following syntax: `echo operation | echomath`.  
Replace `operation` with any mathematical operation. It will pipe the output of the printed command and it will perform the operation.

### Why it is useful?

It is useful when you use regularly C or C++, and you will do `printf("%d", {operation});` or `cout << {operation};`  
If you try to do it in a batch file, it will output the literal string.
You probably will be like "But, I simply do a `set /a` and next an `echo` to print the result".  
Trust me, this will make batch operations more confortable.


### Where can I see the files?

Source code is located into [Source](https://github.com/anic17/Utilities/tree/master/EchoMath/Source) and a converted batch is located into [Bin](https://github.com/anic17/Utilities/tree/master/EchoMath/Bin)

