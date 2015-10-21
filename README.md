#About
***
###工程文件夹分类说明
* 1 **Application**       - 存放AppDelegate和一些系统常量及系统配置文件
* 2 **Base**              - 基本父类，包括父ViewController和一些公用顶层自定义父类 
* 3 **Controller**        - 系统控制器层，继承自Base文件夹的父类
* 4 **View**              - 系统视图层，如代码实现的界面
* 5 **Model**             - 系统中的实体，通过类描述系统中的一些角色和业务，同时包含对这些角色和业务的处理逻辑
* 6 **Handler**           - 系统业务逻辑层，负责处理系统复杂业务逻辑，上层调用是Controller文件夹的类
* 7 **Storage**           - 简单数据存储，主要是一些键值对存储及系统外部文件的存取
* 8 **Network**           - `上层调用是Handler文件夹的类`，通过block实现处理结果的回调
* 9 **Database**          - 提供基于Model层对象的调用`接口`
* 10**Utils**             - 工具类
* 11**Catagories**        - 对现有系统类和自定义类的扩展
* 12**Resource**
* 13**Images.xcasets**
* 14**Supporting Files**
***
