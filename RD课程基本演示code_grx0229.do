*          ===================================
*              第5讲  断点回归设计 (RDD)     
*            Regression Discontinuity Design  
*          ===================================
	
	
*-嘎嘎温馨提示：执行后续命令之前，请先执行如下命令
  global path "D:\stata15\ado\personal\club" //定义课程目录	
  global D    "$path\data"      //范例数据
  global R    "$path\refs"      //参考文献
  global Out  "$path\out"       //结果：图形和表格
  global ex   "$path\examples"  //范例论文和dofiles
  adopath +   "$path\adofiles"  //自编程序 

  cd D:\stata15\ado\personal\club\club_RD0229
  set scheme s2color  

  	shellout "第5讲RDD-grx.pptx"
use"非湖北疫情断点在哪里",clear
browse
***非湖北疫情新增疑似断点在哪里？
twoway (scatter 非湖北累计疑似 以4日为断点) (qfit 非湖北累计疑似 以4日为断点 if 以4日为断点>0)(qfit 非湖北累计疑似 以4日为断点 if 以4日为断点<=0),xline(0)
twoway (scatter 非湖北新增疑似 以4日为断点) (qfit 非湖北新增疑似 以4日为断点 if 以4日为断点>0)(qfit 非湖北新增疑似 以4日为断点 if 以4日为断点<=0),xline(0)
*封城立竿见影
twoway (scatter 非湖北累计疑似 以7日为断点) (qfit 非湖北累计疑似 以4日为断点 if 以7日为断点>0)(qfit 非湖北累计疑似 以7日为断点 if 以7日为断点<=0),xline(0)	
twoway (scatter 非湖北新增疑似 以7日为断点) (qfit 非湖北新增疑似 以7日为断点 if 以7日为断点>0)(qfit 非湖北新增疑似 以7日为断点 if 以7日为断点<=0),xline(0)
	
 ***发普刊用下面几行就够了***

  
 use "疫情对股市影响", clear
browse
*画图
twoway (scatter 综合日市场交易总股数 以1月9日为断点) (qfit 综合日市场交易总股数 以1月9日为断点 if 以1月9日为断点>0)(qfit 综合日市场交易总股数 以1月9日为断点 if 以1月9日为断点<=0),xline(0)
twoway (scatter 综合日市场交易总股数 以1月11日为断点) (qfit 综合日市场交易总股数 以1月11日为断点 if 以1月11日为断点>0)(qfit 综合日市场交易总股数 以1月11日为断点 if 以1月11日为断点<=0),xline(0)
twoway (scatter 综合日市场交易总股数 以1月20日为断点) (qfit 综合日市场交易总股数 以1月20日为断点 if 以1月20日为断点>0)(qfit 综合日市场交易总股数 以1月20日为断点 if 以1月20日为断点<=0),xline(0)
twoway (scatter 综合日市场交易总股数 以1月23日为断点) (qfit 综合日市场交易总股数 以1月23日为断点 if 以1月23日为断点>0)(qfit 综合日市场交易总股数 以1月23日为断点 if 以1月23日为断点<=0),xline(0)
*回归
rdrobust 综合日市场交易总股数 以20日为断点   //三角核Triangular  CCT带宽选择法
rdrobust 综合日市场交易总股数 以20日为断点,all //汇报三种结
rdrobust 综合日市场交易总股数 以20日为断点 ,kernel(uniform) all //均匀核uniform
rdrobust 综合日市场交易总股数 以20日为断点,kernel(epa) all //二次核Epanechnikov
*三种带宽
rdbwselect 综合日市场交易总股数 以20日为断点,all  //CCT IK CV
rdrobust 综合日市场交易总股数 以20日为断点,bwselect(IK)all
rdrobust 综合日市场交易总股数 以20日为断点,bwselect(CV)all

*内生分组检验
DCdensity 以20日为断点,breakpoint(0) generate(Xj Yj r0 fhat se_fhat)





***我们的目标发顶刊***

  *-5.1  图解 RDD 	
	
	
  *---	
  *-1- 生成一份模拟数据
  
	clear
	set obs 4000
	set seed 123
	gen x = runiform()  //均匀分布（0，1）
	gen z = rnormal()*0.5  //其他影响 y 的因素 N(0,1)
	gen T=0
	replace T=1 if x>0.5
	
	gen g0 = 0 + 3*log(x+1) + sin(x*6)/3
	gen g1 = T + 3*log(x+1) + sin(x*6)/3
	
    scatter g0 x, msize(*0.5) 
	scatter g1 x, msize(*0.5) 
	
	gen e = rnormal()/5      // noise
	gen y1 = g1 + 0.5*z + e 
	gen y0 = g0 + 0.5*z + e
	
	gen xc = x-0.5 
	
	label var y1 "Outcome variable (y)"
    label var y0 "Outcome variable (y)"
	label var x  "Assignment variable (x)"
	label var xc "22 (x-c)"
	label var T  "T=1 for x>0.5, T=0 otherwise"
	
	save "RDD_simu_data0.dta", replace  //保存一份数据以备后用
	
  *---
  *-5.2- RDD 图示	 
	 
	use "RDD_simu_data0.dta", clear
	
    *-No Treat effect	                            -------图1-----begin--
      twoway (scatter y0 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (qfit y0 x if T==0, lcolor(red)  msize(*0.4))  ///
	         (qfit y0 x if T==1, lcolor(blue) msize(*0.4)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))	    ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)  ///
			  ytitle("毕业当年月薪(万元)")	
	  *                                             ---------------over---
	  *
	  rdplot y0 x, c(0.5)  //快捷命令，后续会详细介绍
	  
	*-With Treat effect                             -------图2-----begin--
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (qfit y1 x if T==0, lcolor(red)  msize(*0.4))  ///
	         (qfit y1 x if T==1, lcolor(blue) msize(*0.4)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)  ///
			  ytitle("毕业当年月薪(万元)")
	  *                                             ----------------over---
	  *
	  rdplot y1 x, c(0.5)		  
  *---
  *-5.3- 传统估计方法(方案1)存在的问题
	
	* -----------------------------------------------------图3-----begin---
	*-针对全样本进行线性回归 (OLS): 结果有偏   outcome = y1
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (lfit y1 x if T==0, lcolor(red)  msize(*0.4))  ///
	         (lfit y1 x if T==1, lcolor(blue) msize(*0.4)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)       ///
			  ytitle("毕业当年月薪(万元)")	
	  *------------------------------------------------------------over--- 		  
      *-Q: 得到的 ATE (Average Treatment Effect) 是无偏估计吗？原因何在？ 
	  
	*-OLS 导致的偏误2：错误判断 ATE            outcome = y0
	* -----------------------------------------------------图4-----begin---	
      twoway (scatter y0 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (qfit y0 x if T==0, lcolor(red) msize(*0.6))   ///
	         (qfit y0 x if T==1, lcolor(red) msize(*0.6))   ///
             (lfit y0 x if T==0, lcolor(blue) lp(dash) msize(*0.5))  ///
	         (lfit y0 x if T==1, lcolor(blue) lp(dash) msize(*0.5)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  text(3.0 0.3 "Control") text(3.0 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)           ///
			  ytitle("毕业当年月薪(万元)") 
	  *------------------------------------------------------------over--- 			  
	  *-由于 y=f(x) 是非线性的，因此，若在分界点两侧采用直线拟合，
	  * 会错以为存在处理效应
  *---
  *-5.4- RDD 分析中的两种典型估计方法
  
    *-视角1: “断点” (Hahn,Todd，和van der Klaauw, 1999)
	*        “discontinuity at the cut-point.”	
	*-e.g.1 多项式回归：二次函数
	* -----------------------------------------------------图5-----begin---	
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (qfit y1 x if T==0, lcolor(red) msize(*0.6))   ///
	         (qfit y1 x if T==1, lcolor(red) msize(*0.6))   ///
             (lfit y1 x if T==0, lcolor(blue) lp(dash) msize(*0.5))  ///
	         (lfit y1 x if T==1, lcolor(blue) lp(dash) msize(*0.5)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)       ///
			  ytitle("毕业当年月薪(万元)")  
	  *------------------------------------------------------------over--- 			  
	  *-评述: 重点在于分析 cut-point 处的跳跃(jump), 
	  *       跳跃的方向和幅度是评估处理效应的主要依据。
	  
	*-e.g.2 核加权局部多项式平滑 (Kernel-weighted local polynomial smoothing)
	  help lpoly 
	* -----------------------------------------------------图5-----begin---	
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (lpoly y1 x if T==0, lcolor(red) msize(*0.6))   ///
	         (lpoly y1 x if T==1, lcolor(red) msize(*0.6))   ///
             (lfit y1 x if T==0, lcolor(blue) lp(dash) msize(*0.5))  ///
	         (lfit y1 x if T==1, lcolor(blue) lp(dash) msize(*0.5)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)       ///
			  ytitle("毕业当年月薪(万元)")  
	  *------------------------------------------------------------over--- 		  
	  
	  *-快捷命令(随后还会详细讲解)	  
        rdplot y1 x, c(0.5)      //自动选择高次项的阶数
		rdplot y1 x, c(0.5) p(2) //自行设定, 只加入一次项和二次项
   	    rdplot y1 x, c(0.5) p(1) //自行设定, 一次线性关系
	  
	*-视角2: “局部随机化” (Lee,2008)
	*
    *-e.g. 局部线性回归
	* -----------------------------------------------------图6-----begin---
	 
	  
	  local h=0.1           // width of window, double sides
	  local cL = 0.5 - `h' 
	  local cR = 0.5 + `h'
	  gen left  = (x>0.5-`h')&(x<0.50)
	  gen right = (x>0.50)&(x<0.5+`h')
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3))  ///
             (lfit y1 x if (T==0&left==1) , lcolor(red)  msize(*0.4))  ///
	         (lfit y1 x if (T==1&right==1), lcolor(blue) msize(*0.4)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  xline(`cL' `cR', lp(dash) lc(black*0.2))      ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 0.5 "Cut point" 1)       ///
			  ytitle("毕业当年月薪(万元)")		  

****老铁，咱们修改带宽瞧瞧

	  local method "qfit"   //二次函数
	  local method "lpoly"  //核加权多项式
	  local h=0.1
	  local cL = 0.5 - `h' 
	  local cR = 0.5 + `h'
	  dropvars left right
	  gen left  = (x>0.5-`h')&(x<0.50)
	  gen right = (x>0.50)&(x<0.5+`h')
      twoway (scatter y1 x, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
             (`method' y1 x if T==0, lcolor(red) msize(*0.4))  ///
	         (`method' y1 x if T==1, lcolor(red) msize(*0.4))  ///	  
             (lfit y1 x if (T==0&left==1) , lcolor(blue) msize(*0.4))  ///
	         (lfit y1 x if (T==1&right==1), lcolor(blue) msize(*0.4)), ///
	          xline(0.5, lpattern(dash) lcolor(gray))       ///
			  xline(`cL' `cR', lp(dash) lc(black*0.2)) ///
			  text(3.5 0.3 "Control") text(3.5 0.7 "Treat") ///
			  legend(off) xlabel(0 `cL' 0.5 "CP(.5)" `cR' 1)  ///
			  ytitle("毕业当年月薪(万元)")	xtitle("")		  



*-5.5  RDD 应用举例1: 美国参议员选举 -- 在任候选人是否更有竞选优势? 
	shellout "rdrobust-Calonico-SJ14-2.pdf" // pp.934-944
	shellout "rdrobust-SJ-17-2.pdf"         // pp.389-399
    shellout "Lee_2008_Selection.pdf"       // 美国国会选举
	  	
	  use "rdrobust_senate.dta", clear
	  des2
	  sum


*划水跑  
  *画图
rdplot  vote margin,p(2)
twoway (scatter vote margin) (qfit vote margin if margin>0)(qfit vote margin if margin<=0),xline(0)

*回归
rdrobust vote margin   //三角核Triangular  CCT带宽选择法
rdrobust vote margin,all //汇报三种结
rdrobust vote margin ,kernel(uniform) all //均匀核uniform
rdrobust vote margin,kernel(epa) all //二次核Epanechnikov
*三种带宽
rdbwselect vote margin,all  //CCT IK CV

*内生分组检验  http://emlab.berkeley.edu/~jmccrary/DCdensity/
DCdensity margin,breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
sysdir

*---------------顶刊分割线------------------------------
cd D:\stata15\ado\personal\mypaper\paper5_百度指数
use 百度指数.dta,clear
browse
rename date 日期
save 百度指数1.dta,replace

use 疫情4.dta,clear
merge m:m 日期 using 百度指数1.dta, nogen  

*1.画图
	*-基本图形
	  rdplot vote margin   // binned means
	  rd vote margin, mbw(100) graph  // scatter 


	  *美化  高亮显示？
	  *---------------------------------------------------
		  #d ;
		  rd vote margin, mbw(100) graph   ///
			 lineopt(lcol(black red) lw(*0.9))  ///
			 scopt( mcol(black*0.5) msize(*0.3) msy(+)  ///
					ytitle("vote share at next election") 
					xtitle("margin")
					t1("RD Plot: Senate elections data")
				   ) ;
		  #d cr
	  *---------------------------------------------------

 *个人认为最美：可以使用 help lpoly 自行估计两边的拟合线，然后自己绘图(比较灵活)
 *-------------------------------------------------------------------------
  rdrobust vote margin, p(2)  //选择最优带宽
  cap drop T
  gen T = margin>0
  eret list
  local h: dis %4.2f `e(h_l)'  //最优带宽的数值,最关键的一步
  *-亦可自己手动设定(初步分析中常用的办法)
   local h = 20
  local cL = 0.0 - `h' 
  local cR = 0.0 + `h'
  gen left  = (margin>-`h')&(margin<0.0)
  gen right = (margin>0.0 )&(margin<+`h')
  twoway (scatter vote margin, msymbol(+) msize(*0.4) mcolor(black*0.3)) ///
		 (lpoly  vote margin if T==0, lcolor(red) msize(*0.4))  ///
		 (lpoly  vote margin if T==1, lcolor(red) msize(*0.4))  ///
		 (lfit vote margin if (T==0&left==1) , lcolor(blue) msize(*0.4))  ///
		 (lfit vote margin if (T==1&right==1), lcolor(blue) msize(*0.4)), ///
		  xline(0.0, lpattern(dash) lcolor(gray))     ///
		  xline(`cL' `cR', lp(dash) lc(black*0.3))    ///
		  text(80 -35 "Control") text(80 35 "Treat")  ///
		  legend(off) xlabel(`cL' 0.0 "0.0" `cR')     ///
		  subtitle("RD Plot: Senate elections data")  ///
		  ytitle("Vote share at t+2") xtitle("Vote margins")
 *-------------------------------------------------------------------------
  
    drop left right

*2.回归

	*-A-基本估计结果: 使用 -rdrobust- 命令

	  rdrobust vote margin  //自动选择最优带宽

	  *-不同带宽下的 LATE 及其置信区间 (95%CI)  
		rd vote margin, mbw(40(20)200) z0(0) bdep 
			
  
	*-B-局部线性回归: 给老铁论证下RD就是变形后的OLS+Dummy！！！采用 regression 命令自行估计
		
		rdrobust vote margin 
		local h = e(h_l)       //获取最优带宽，也可以用 -rdbdselect- 命令
		*local h = 17.708      //与上一行命令等价
		cap drop Treat
		gen Treat = (margin>0) // Treat=1 if margin>0, Treat=0 if margin<=0
		reg vote Treat margin if (margin>=-`h')&(margin<=`h')
	   
*3.选择不同带宽的结果
	  rdrobust vote margin //Calonico, et al. (CCT,2014,SJ) Data-driven 带宽
	  est store hCCT  
	  rdrobust vote margin, h(10) //自行设定带宽
	  est store h10
	  rdrobust vote margin, h(15)
	  est store h15
	  rdrobust vote margin, h(20)
	  est store h20
	  rd vote margin, mbw(50 100 200) // Imbens-Kalyanaraman(2009), Optimal bandwidth, h
	  est store hImbens

	  local m "hCCT h10 h15 h20 hImbens"
	  esttab `m', mtitle(`m') b(%4.3f) nogap s(h_l w50 w100 w200)  ///
		   addnote("h_l, w50, w100, w200 表示对应模型中使用的带宽")
  
  
*4.加入控制变量，稳健性标准误

	  *-定义一些新变量
		qui tab class, gen(dumclass)
		drop dumclass1
		gen lnpop = ln(population)
	  
	  xi:rdrobust vote margin, covs(i.class)
	  estadd local Control "A"
	  est store m_z1
	  rdrobust vote margin, covs(dumclass* termshouse termssenate)
	  estadd local Control "A,B"
	  est store m_z2  
	  rdrobust vote margin, covs(dumclass* termshouse termssenate lnpop)
	  estadd local Control "A,B,C"
	  est store m_z3
	  
	  *-类似于 White(1980) 的异方差稳健性标准误(SE)
	  rdrobust vote margin, vce(hc0)  // 其它选择 hc1, hc2, hc3
	  est store m_White
	  *-在州层面上的聚类标准误(clusted robust SE)
	  * 假设干扰项在各州内部相关，州与州之间的干扰项则不相关
	  rdrobust vote margin, vce(cluster state)
	  est store m_cluster
	  
	  local m "m_z1 m_z2 m_z3 m_White m_cluster"
	  esttab `m', mtitle(`m') b(%4.3f) nogap s(h_l N Control)  ///
		   addnote("h_l 表示对应模型中使用的带宽" ///
				   "A: dumclass2 dumclass3"        ///
				   "B: termshouse termssenate"     ///
				   "C: lnpop"                      ///
				   )  


*-----------------------------
*5.结果的有效性检验

	*-RDD 的有效性依赖于如下两个假设：

	 *-A1: 驱动变量(margin)不受人为操控 
	 * - 驱动变量(本身)的在断点处的分布是连续的, 不存在明显的断点;
	 * - 检验方法: 绘制分配变量的直方图
	 
	 *-A2: 平滑性假设
	 * - 除Treat变量外，其他影响outcome的协变量在分界点两侧不应有明显的跳跃
	 * - 检验方法:
	 *   - 回归法, 使用 -rd- 或 -rdrobust- 命令分析协变量与x的关系
	 *   - 图形法, 使用 -rdplot- 观察协变量在 cut-point 处是否跳跃
 
	 *---------
	 *-检验 A1: 驱动变量(margin)不受人为操控 
	   
	   histogram margin
	   
	   histogram margin, xline(0) fcolor(black*0.1) lcolor(black) ///
			  scheme(s1mono) 
			  
	   graph export "$Out\his_margin.wmf", replace  //输出图片		  
	 

	 *---------
	 *-检验 A2: 平滑性假设
	 
	   *- 回归法
		local covs "dumclass2 dumclass3 termshouse termssenate lnpop"
		global models ""
		foreach z in `covs' {
		   qui rdrobust `z' margin
		   est store m_`z'
		   global models "$models m_`z'"
		}
		dis "$models"
		esttab $models, mtitle($models) b(%4.3f) nogap s(pv_cl pv_rb) ///
			   addnotes("pv_cl: Conventional p-value" "pv_rb: robust p-value") 

	   *-图形法
	   *-以 termssenate 变量为例(可以依次绘制其他控制变量对应的图形): 
		 local z "termssenate"  //更改其他变量, 同时要修改 ytitle() 选项
		 rdplot `z' margin,          ///
		   graph_options(            ///
			  subtitle("(a)")        ///
			  ytitle("候选人参议院经历(termssenate)")   ///
			  xtitle("候选人当年选票与竞争者选票之差(margin)")  ///
			  graphregion(color(white)) legend(off)      ///
			  xline(0, lp(dash) lc(black*0.5))) 
		 graph export "$Out\termssenate.wmf", replace  //输出图片	
	   
	   *-也可以条件直方图
		#d ;
		 cmogram termshouse margin, 
			graphopts(
			   ytitle("候选人参议院经历(termssenate)")
			   xtitle("候选人当年选票与竞争者选票之差(margin)")  
			   xline(0, lp(dash) lc(black*0.5))
			   scheme(s1mono)
			);
		#d cr
		
*-5.5 	RDD 应用举例2:2017AER_Meng, Kyle C(自学)
*彩蛋RKD和多断点

*拐点
	  use "rdrobust_senate.dta", clear
rdrobust vote margin, fuzzy(margin)  all deriv(1)
		
*多断点
. ssc install github, replace  //安装 github 命令, 若已有，可忽略此步骤
. github install iphone7725/rdmulti
. help rdmc		
rdmcplot vote margin, c(c)
    shellout "多断点.pdf"     // pp.7  Sharp RDD


*小样本也不怕
ssc install st0435.pkg 
rdrbounds //敏感性检验
rdsensitivity
*-5.6  RDD 参考资料

  *-几份重要的 PPT
  
    shellout "$R\Yang_2017_RDDa.pdf"     // pp.7  Sharp RDD
	shellout "$R\Yang_2017_RDDb.pdf"     // Fuzzy RDD
	shellout "$R\Yang_2017_RDD_PPT.pdf"	 // 合集
	
	shellout "$R\Sylvia-2015-PPT-RDD.pdf"      //带有中文翻译，讲的很清楚
	
	shellout "$R\lecture_4_-_rdd.pdf"          //Fabian Waldinger, 2010
	
    shellout "$R\Regression_Discontinuity.pdf" //Jeremy Magruder, 2009
	
	shellout "$R\楊子霆-2017-断点回归方法的介绍与应用.pptx"
	
	
  *-几篇重要的文章
	
	*-该文对各种内生性问题的处理方法进行了全面介绍，提供了范例
	*-Nichols, Austin. 2007.  
	*   Causal Inference with Observational Data." 
	*   The Stata Journal 7(4): 507–541
        shellout "$R\Nichols_2007.pdf"
	
    *-Lee, D., T. Lemieux, 2010, 
    *   Regression Discontinuity Designs in Economics, 
    *   Journal of Economic Literature, 48: 281-355.
        shellout "$R\Lee_Lemieux_2010_JEL.pdf"
		
	*-Imbens, G., T. Lemieux, 2008, 
	*   Regression discontinuity designs: A guide to practice, 
	*   Journal of Econometrics, 142 (2): 615-635.  
	    shellout "$R\Imbens_2008_JE_Guide.pdf"   
		
    *-Barrera-Osorio, F., D. Raju, 2010, 
	* Evaluating a test-based public subsidy program for 
	* low-cost private schools: 
	* Regression-discontinuity evidence from Pakistan.
	* Working paper
	    shellout "$R\Barrera_Raju_2010_RDD.pdf"  // RD 应用，写的很细致
		
    * Lee, D. S., 2008, (Excellent paper) 
    *   Randomized experiments from non-random selection 
	*   in US House elections, 
    *   Journal of Econometrics, 142 (2): 675-697.
        shellout "$R\Lee_2008_Selection.pdf"     // 已经被引用 300 多次
		
	*-Fuji, D., G. Imbens, K. Kalyanaraman, 2009, 
	*   Notes for matlab and stata regression discontinuity software, 
	*   Working Paper.	
		shellout "$R\rd_Imbens_procedure.pdf" 
		adoedit "rdob.ado"
		
	*-这本小书提供了 RDD 分析中的各种建议和实操指南
    *-Jacob, R., P. Zhu, M. A. Somers, H. Bloom, 2012, 
	*   A practical guide to regression discontinuity, MDRC working paper.		
		shellout "$R\Jacob_2012_RDD_Guide.pdf" //RDD 的前世今生, pp.2
			
  *-经典应用

    *-Hoekstra, M., 2009, The effect of attending the flagship state  
    *  university on earnings: A discontinuity-based approach, 
    *  Review of Economics and Statistics, 91 (4): 717-724.
       shellout "$R\Hoekstra_2009_RDD.pdf"   //名校的收入效应
       shellout "$R\Yang_2017_RDDa.pdf"      //pp.7对该文有介绍
