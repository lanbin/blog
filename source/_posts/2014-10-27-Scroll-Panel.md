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
		<div id="listBox">       <!-- 蓝色的列表部分 -->
			<div id="list"></div>
		</div> 
		<div id="scroll">      <!-- 红色的滑动块部分 -->
			<div id="block"></div>
		</div>
	</div>

#功能需求：

- 异步加载数据
- 根据列表数据的多少来计算滑动块高度
- 滑动块与列表联动
	+ 支持鼠标点住拖动定位
	+ 支持鼠标滚轮定位
	+ 支持点击定位
- 支持定位到某个元素的高度

##1. 异步加载数据

通过异步接口获取数据之后，使用[Mustach](https://github.com/janl/mustache.js)将数据与模板拼合。
需要注意的是
> 字符串的拼合推荐使用数组的join方法(提升效率)。

	var html = ["<div>", "Hello world!", "</div>"].join("")

	console.log(html) //"<div>Hello world!</div>"

##2. 根据列表数据的多少来计算滑动块高度

根据 **list** 与 **listBox** 的高度计算出一个 **rate**
通过 **rate** 比例计算来得出

	var rate = parseFloat($("#list").height() / $("#listBox").height())

	$("#block").height($("#scroll").height() * rate)

##3. 定位

Feature List里面提到的所有的定位功能其实都是一个核心的算法。
其他的操作只是激活这个算法的入口而已。

	//根据目标滚动块需要到达的目标高度和最大高度之间的关系来决定最重目标高度的值
	function cTop(targetTop, maxTop) {
		var tTop = 0
		if (targetTop > maxTop) {
			tTop = maxTop
		} else if (targetTop < 0) {
			tTop = 0
		} else {
			tTop = targetTop
		}
		return tTop
	}

###3.1支持鼠标点住拖动定位

我一开始将**mousedown**、**mouseup**、**mousemove**，全部都绑定在滚动块上
通过计算两个事件的evt.pageY值来判断滚动块需要怎么移动。

但是这样会出现一个问题：**只要鼠标移出滚动块的上方，滚动块滚动即停止**

要解决这个问题，只要将**mouseup**、**mousemove**都绑定在document上。
同时判断通过标识来判断当前是否要需要移动滚动块

	$block.on("mousedown", function(evt) {
		move = true
		oy = evt.pageY

		body.on("selectstart", function() {
			return false
		})
	})

	$(document).on("mouseup", function() {
		move = false
		body.off("selectstart")
	}).on("mousemove", function(evt) {
		if (move) {
			cy = evt.pageY
			//计算移动距离
		}
	})

同时，如果鼠标仍然在**mousedown**的状态，划过页面上时，会导致能被选中的元素统统被选中，造成一大片蓝色选中区域。
要解决这个问题，只要在上述两个事件回调中为body添加事件监听 **selectstart**

	$block.on("mousedown", function(evt) {
		//...code
		body.on("selectstart", function() {
			return false
		})
	})

	$(document).on("mouseup", function() {
		//...code
		body.off("selectstart")
	})

这样，鼠标在滚动块点击之后，整个body都变成不可被选中。
不管你鼠标如何拖动，都不会出现蓝色的选中区域。
在**mouseup**之后，去掉该事件的监听，则将body恢复正常


###3.2支持鼠标滚轮定位

为了兼容不同系统浏览器对于鼠标滚轮的支持，引入了如下的方法

	function getDeltaFromEvent(e) {
		var evt = e.originalEvent,
			deltaX = evt.deltaX || 0,
			deltaY = -1 * (evt.deltaY || evt.detail)

		if (typeof deltaX === "undefined" || typeof deltaY === "undefined") {
			// OS X Safari
			deltaX = -1 * evt.wheelDeltaX / 6
			deltaY = evt.wheelDeltaY / 6
		}

		if (evt.deltaMode && evt.deltaMode === 1) {
			// Firefox in deltaMode 1: Line scrolling
			deltaX *= 10
			deltaY *= 10
		}

		if (deltaX !== deltaX && deltaY !== deltaY /* NaN checks */ ) {
			// IE in some mouse drivers
			deltaX = 0
			deltaY = evt.wheelDelta
		}

		return [deltaX, deltaY]
	}

此方法来自[perfect-scrollbar.js line 346](https://github.com/noraesae/perfect-scrollbar/blob/master/src/perfect-scrollbar.js)

	$("#listBox").on("mousewheel", function(evt) {
		
	}).on("DOMMouseScroll", function(evt) {
		//火狐
	})

在火狐浏览器下需要监听 **DOMMouseScroll** 事件


###3.3支持点击定位

点击定位比较简单，思路就是取点击的坐标作为滚动块中心的坐标，来判断滚动块应该滚动到哪。

##4.支持定位到某个元素的高度

这个也很简单，计算某个元素在list中的位置，然后倒退滚动块的位置。


#同页面多实例

	win.scrollPanel = function(_opt) {
		return sp(_opt)
	}

	var sp = function(_opt) {return {}} //scrollPanel初始化方法

	var scorllPanel_1 = scrollPanel({}),
		scorllPanel_2 = scrollPanel({})


以上

