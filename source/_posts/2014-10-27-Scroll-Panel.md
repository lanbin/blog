title: Scroll Panel 开发记
categories: code
date: 2014-10-27 14:22:26
tags: scrollpanel
---

产品中，提出了需要做一个类似于优酷的播放列表.
这是一个几乎所有UI组件库都会提供的一个功能。
我之前并未有阅读过相关的源码，基本上全凭自己的理解来进行编码。
在开发中着实遇到了一些问题,将记录之。
<!--more-->
首先,我们来看看Scroll Panel的图

![](http://githubio.qiniudn.com/9F16C061-8613-4506-BA52-F02F0627E47E.png "优酷的播放列表")

根据蓝色和红色的线框分开两个部分

	<div id="scrollPanel">
		<div id="list"></div> <!-- 蓝色的列表部分 -->
		<div id="scoll">      <!-- 红色的滑动块部分 -->
			<div id="block"></div>
		</div>
	</div>

#功能需求：

- 异步加载数据
- 根据列表数据的多少来计算滑动块高度
- 支持定位到某个元素的高度
- 滑动块与列表联动
	+ 支持鼠标滚轮
	+ 支持点击定位
	+ 支持鼠标点住拖动


##异步加载数据

通过异步接口获取数据之后，使用[Mustach](https://github.com/janl/mustache.js)将数据与模板拼合。
需要注意的是
> 字符串的拼合推荐使用数组的join方法。

	var html = ["<div>", "Hello world!", "</div>"].join("")
	console.log(html) //"<div>Hello world!</div>"
