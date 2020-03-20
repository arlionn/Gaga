*第一类：回归结果
 . sysuse auto, clear 

 . reg price mpg length turn if foreign==0
. est store Domestic 
. reg price mpg length turn if foreign==1
. est store Foreign 
. coefplot Domestic Foreign,  ///
    drop(_cons)               ///
    xline(0, lp(dash) lc(black*0.3)) 
  *-Note: 如果想要调换 X 轴和 Y 轴，可以添加 vertical 选项, 图略
	*不同解释变量比较
  reg price mpg length turn if foreign==0
est store Domestic

reg price mpg length turn if foreign==1
est store Foreign

reg weight mpg length turn if foreign==0
est store Domestic_w  //更换了被解释变量

reg weight mpg length turn if foreign==1
est store Foreign_w   //更换了被解释变量

#d ;
coefplot 
  (Domestic, label("国产汽车"))  
  (Foreign , label("进口汽车")), bylabel(Price) || 
  (Domestic_w) (Foreign_w), bylabel(Weight) ||
  , 
  drop(_cons) byopts(xrescale) 
  xline(0, lp(dash) lc(black*0.3))
  ;
#d cr
graph export "图5：不同被解释变量回归的比较.png", replace

*第二类：描述统计
*1标记剪头
 ssc install arrowplot
 . sysuse "nlsw88.dta", clear
. decode occupation, gen(occu_str) maxlength(6)
. arrowplot wage hours, groupvar(occu_str)
. graph export "图7：arrowplot 基本绘图.png", replace
*2三角关系
ssc install triplot,replace
clear
input a1 a2 a3 str10 name

10 10 80 John
80 10 10 Fred
25 25 50 Jane
90 5 5 Helen
0 0 100 Ed
50 25 25 Kate
20 60 20 Michael
25 25 50 Darren
5 90 5 Samar

end 

list

triplot a1 a2 a3, ///
mlabel(name) mlabcolor(black) mcolor(blue) ///
mlabsize(*0.9) max(100) ///
title("Opinion a1 a2 a3")


*3分组政策效果

ssc install stripplot, replace // 下载并更新命令

sysuse bplong, clear
egen group = group(age sex), label


#d ;
stripplot bp*, bar over(when) 
by(group, compact col(1) note("")) 
yscale(reverse) 
subtitle(, pos(9) ring(1) nobexpand
bcolor(none) placement(e)) 
ytitle("") 
xtitle("Blood pressure (mm Hg)") ;
#d cr

*4快速6组描述统计

ssc install sixplot //下载命令
 sysuse nlsw88.dta
    . sixplot age

