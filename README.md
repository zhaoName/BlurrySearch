# BlurrySearch

获取通讯录信息: 授权；兼顾iOS9之前(ABAddressBookRef)和之后(CNContactStore)方法改变获取通讯录内容

按字母排序：数据源可以是全中文、中文英文字符混合

模糊查询：输入框中可以输入中文、字母、字符

        但是数据较大时，按字母查询会卡线程，这里只是给个Demo，项目中所以最好用数据库匹配。

添加数据： 可添加字符串数据，也可添加模型数据

![image](https://github.com/zhaoName/BlurrySearch/blob/master/BlurrySearch.gif)
