# 基于PRBS58多项式的60bit并行加/解扰器

## 加/解扰多项式

### $G(x) = x^{58} + x^{39} + 1$

## 功能验证方法

### prbs31码流作为TX端的激励，输入到串行加扰器，再经过1 to 60解串器、60路并行解扰器和60 to 1串行器得到一串数据，这一串数据应与激励相同

![1](schematic.png "示意图")
