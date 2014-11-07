echo "hexo 开始编译并发布！";
hexo d -g;
echo "增加新的文件入库....";
git add .;
echo "提交内容update";
git commit -a -m "update";
echo "推送文章指远程仓库";
git push origin master;
