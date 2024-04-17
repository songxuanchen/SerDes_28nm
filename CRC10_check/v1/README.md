# 串行CRC校验

在./src/para.v中配置参数，可以实现任意bit的数的CRC校验

例：
```
/********   CRC-10  ********/

//CRC多项式G(x) = x^{10} + x^9 + x^5 + x^4 + x + 1
`define CRC_POLY    10'b10_0011_0011

//CRC多项式的长度
`define CRC_LENGTH  10

//输入数据的bit位数
`define DATA_LENGTH 403

//输入的数据
`define DATA        403'h02bb1413a1a9ebdc14c38084f0b7bc325a10d89bc8dc5b4fde6e995b4c9e2eb1b5bcc94b38dcf55b5181e49ce1d63ce53da1b

//大于log2(DATA_WIDTH)即可
`define CNT_WIDTH   10
```



