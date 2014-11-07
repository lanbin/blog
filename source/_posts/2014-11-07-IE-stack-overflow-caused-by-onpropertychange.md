title: 由onpropertychange引起的IE stack overflow
categories: code
date: 2014-11-07 12:56:21
tags: [IE, Flash, onpropertychange, onchange, oninput]
---

今天，在调试其他功能的时候，发现页面在IE下有报错 : "堆栈溢出"。
<!--more-->
报错直接定位到了文件中

    document.attachEvent('onpropertychange', function(){
        ...
        })


#1、onpropertychange

onpropertychange事件是IE特有的事件，只要当前对象属性发生改变，都会触发事件。
之所以会用到这个事件，是因为在IE的一个页面下同时满足

- Flash
- URL中有Hash

这两个条件时，页面的title会被重写为URL中Hash的值。

首先将页面的title保存，然后当**onpropertychange**事件触发的时候，再重置title

    var rememberTitle = document.title
        document.attachEvent('onpropertychange', function() {
             if (document.title != rememberTitle) { //重要！
                   document.title = rememberTitle;
            }
        });

如果代码中没有*if*这个condition，就必定会导致**堆栈溢出**。
原因是：
每次响应**onpropertychange**事件后，设置title时，其实就是导致了document的属性发生改变。
那么**onpropertychange**就会一直被触发，最终导致**堆栈溢出**！

不过还有其他的方式可以解决

    setInterval(function(){
            document.title = 'your title'
        }, 200)  

不过这样可能大家觉得会有点消耗性能。

#2、onchange、oninput

说到修改、变化引起的事件，还有**onchange**和**oninput**

###onchange触发满足条件

- 当前对象属性改变，并且是由键盘或鼠标事件激发的（脚本触发无效）
- 当前对象失去焦点(onblur)

###oninput触发满足条件
- 只有value值发生变化的时候才会触发



