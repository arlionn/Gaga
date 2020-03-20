
*-注意：执行后续命令之前，请先执行如下命令

  
 cd  D:\stata15\ado\personal\club
  clear all
set more off

putdocx begin                     //新建 Word 文档
putdocx paragraph, halign(center) //段落居中

*-定义字体、大小等基本设置
putdocx text ("附：文中待插入表格"), ///
        font("华为楷体",16,black) bold linebreak  

*-保存名为 My_Table.docx 的 Word 文档        
putdocx save "$Out\My_Table.docx", replace


  


*----------------
*- Summary Stats 
*----------------

*-调入数据
sysuse   nlsw88.dta,clear
labelbook 	  
describe
	  *-均值
	  tabstat hours occupation  , ///
	          by(race) f(%4.2f)
			  
	  *-中位数
	  tabstat hours occupation   , ///
	          by(race) f(%4.2f) s(p50)	
			  
	  *-密度函数对比
	  twoway (kdensity occupation if  race)  ///
	         (kdensity occupation if ~race), ///
			 xtitle("occupation")             ///
			 legend(label(1 "race") label(2 "Non-race"))

	  twoway (kdensity hours if  race)  ///
	         (kdensity hours if ~race), ///
			 xtitle("hours")             ///
			 legend(label(1 "race") label(2 "Non-race"))

*-----Table 1-----
 
  global x "race age "  //个人特征help macro, 存放解释变量
  

  //存放被解释变量的全局暂元
  sum2docx  hours occupation $x  using "$Out\My_Table.docx", append ///
         obs mean(%9.2f) sd min(%9.0g) median(%9.0g) max(%9.0g) ///
          title("表 1: 描述性统计") 


*-Note: 选项 append 的作用是将这张新表追加到 "My_Table.docx" 尾部, 下同.


*-----Table 2-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

corr2docx   hours occupation $x   using "$Out\My_Table.docx", append ///
          star(* 0.05) fmt(%4.2f) ///
          title("表 2：相关系数矩阵")


*-----Table 4-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x , r
est store m1
qui reg hours  $x, 
est store m2
qui reg   occupation $x, r
est store m3
qui reg   occupation $x, 
est store m4

reg2docx m1 m2 m3 m4 using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表4: 基本回归结果")  

 
 *-----Table 5-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x , r
est store m1
qui reg hours  $x , r
est store m2
qui reg   occupation $x , r
est store m3
qui reg   occupation $x, r
est store m4

reg2docx m1 m2 m3 m4  using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表5: 异质性：分是否城镇户口回归结果")



 
  *-----Table 7-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x , r
est store m1
qui reg  hours  $x, r
est store m2
qui reg  occupation  $x , r
est store m3
qui reg  occupation  $x, r
est store m4

reg2docx m1 m2 m3 m4  using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表7: 异质性：分代际20后-40后以及50、60后两组回归结果") 
 
  *-----Table 9-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x , r
est store m1
qui reg hours  $x , r
est store m2
qui reg   occupation $x , r
est store m3
qui reg   occupation $x , r
est store m4

reg2docx m1 m2 m3 m4  using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表9: 异质性：分家庭总收入水平回归结果") 
 

   *-----Table 11-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x, r
est store m1
qui reg hours  $x , r
est store m2
qui reg   occupation $x , r
est store m3
qui reg   occupation $x , r
est store m4

reg2docx m1 m2 m3 m4 using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表11: 异质性：分婚姻状况回归结果") 

 
 
  *-----Table 13-----
putdocx begin
putdocx pagebreak
putdocx save "$Out\My_Table.docx", append

qui reg  hours  $x  , r
est store m1
qui reg hours  $x  , r
est store m2
qui reg   occupation $x  , r
est store m3
qui reg   occupation $x  , r
est store m4

reg2docx m1 m2 m3 m4  using "$Out\My_Table.docx", append ///
          ar2(%9.2f) b(%9.3f) se(%7.2f) ///
 title("表13: 稳健性：加入吸烟和饮酒回归结果") 

 
shellout "$Out\My_Table.docx"  //大功告成！打开生成的 Word 文档

