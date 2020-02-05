<%@page contentType="text/html"%><%@page pageEncoding="UTF-8"%><%@include file="../Framework/TreeGridFramework.jsp"%><%
/*-----------------------------------------------------------------------------------------------------------------
Example of TreeGrid using synchronous (submit, non AJAX) communication with server
Example of simple table without tree
Uses HSQLDB database Database (.properties and .script) as data and XML file DBDef.xml as TreeGrid layout
Uses routines in TreeGridFramework.jsp to load and save data
! Check if JAVA application has write access to ../Database.properties and ../Database.script files
! Don't forget to copy hsqldb.jar file to JAVA shared lib directory
------------------------------------------------------------------------------------------------------------------*/

//------------------------------------------------------------------------------------------------------------------
response.addHeader("Cache-Control","max-age=1, must-revalidate");

// --- Database connection ---
java.sql.Statement Cmd = getHsqlStatement(request,out,"../Database","sa","",true);

// --- Save data to database ---
org.w3c.dom.Element[] Ch = getChanges(request.getParameter("TGData"));
if(Ch!=null){
   try {
      for(int i=0;i<Ch.length;i++){
         org.w3c.dom.Element I = Ch[i];
         String id = getId(I); if(id.equals("")) continue; // Error
         if(isDeleted(I)){ // Deleting
	         Cmd.executeUpdate("DELETE FROM TableData WHERE ID="+id);  
            }
         else if(isAdded(I)){ // Adding
            String[] Names = {"id","Project","Resource","Week","Hours"};
            boolean[] IsString = {false,true,true,false,false};
            Cmd.executeUpdate("INSERT INTO TableData(ID,Project,Resource,Week,Hours) VALUES(" + toSQLInsert(I,Names,IsString) + ")");
            }
         else if(isChanged(I)){ // Updating
            String[] Names = {"Project","Resource","Week","Hours"};
            boolean[] IsString = {true,true,false,false};
            Cmd.executeUpdate("UPDATE TableData SET " + toSQLUpdate(I,Names,Names,IsString) + " WHERE ID=" + id);
            }
         }
      }
   catch(Exception ex){
      out.print("Error in saving data !<br>");
      out.print(ex.getMessage());
      }
   }

// --- Load data from database ---
java.sql.ResultSet R = Cmd.executeQuery("SELECT * FROM TableData");
String[] Names = {"id","Project","Resource","Week","Hours"};
String Str = toHTMLString(getTableXML(R,Names));
R.close();
//------------------------------------------------------------------------------------------------------------------
%><html>
   <head>
      <script src="../../../Grid/GridE.js"> </script>
      <style>
         /* Examples shared styles */
         .ExampleHeader { font:normal 16px Arial; color:blue; }
         .ExampleHeader b { color:#800; }
         .ExampleHeader i { color:black; font-style:normal; font-weight:bold; }
         .ExampleHeader u { text-decoration:none; color:#0B0; font-weight:bold; padding:0px 2px 0px 2px; }
         .ExampleName { font:bold 30px Arial; padding:5px 0px 5px 0px; }
         .ExampleShort { font:italic 15px Arial; margin-bottom:10px; padding-top:5px; }
         .ExampleDesc { margin:0px 5px 10px 5px; padding:5px; border:1px solid #AAA; }
         .ExampleErr { margin:50px auto 10px auto; padding:5px; line-height:30px; border:1px solid black; color:red; width:800px; text-align:center; display:none; }
         .ExampleBorder { margin:0px 5px 5px 5px; clear:both; zoom:1; }
         .ExampleDesc ul { padding:0px 0px 0px 15px; margin:10px 0px 0px 0px; }
         .ExampleDesc li { padding-bottom:8px; line-height:18px; }
         .ExampleDesc h4 { display:inline; font:bold 15px Arial; line-height:20px; padding-left:6px; padding-right:6px; background:#87DAE5; border:1px solid #888; color:black; margin:0px; font-style:normal; }
         .ExampleDesc u { text-decoration:none; font-size:11px; }
         .ExampleDesc .Link { text-decoration:underline; color:blue; cursor:pointer; }
         .ExampleForm input { margin:0px 0px 0px 5px; }
      </style>
   </head>
   <body>
      <center class="ExampleHeader"><script>document.write(location.href.replace(/(.*)(\/Examples\/|\/ExamplesGantt\/)([^\/]+)\/([^\/]+)\/([^\/]+)$/,"$2<b>$3</b>/<i>$4</i>/$5").replace(/([^<]|^)(\/|\.)/g,"$1<u>$2</u>"));</script></center>
      <center class="ExampleName">Using TreeGrid JSP framework</center>
      <center class="ExampleShort">Creates grid data from and saves changes back to database using <b>form submit</b> and <b>TreeGrid JSP framework</b></center>
      <div class="ExampleErr">
         <script> if(location.protocol=="file:") document.write("<style>.ExampleDesc, .ExampleBorder {display:none;} .ExampleErr { display:block; } </style>"); </script>
         Do <b>not</b> run this file locally!<br />Run it from your local or remote web http server where is installed JAVA JRE.<br>
      </div>
      <div class="ExampleDesc">
         <i>Source files:</i> <h4>Framework.jsp</h4> (this html page and also server script that generates and processes XML data), 
         <a href="DBDef.xml" target="_blank"><h4>DBDef.xml</h4></a> (static XML layout), 
         <h4>../Database.*</h4> (source SQL database, table <b>TableData</b>),
         <h4>../Framework/TreeGridFramework.jsp</h4> (TreeGrid JSP framework support script, included into <b>Framework.jsp</b> script)
      </div>
      <div class="ExampleDesc">
         <h4 style="background:#FCC;">You have to copy file <b style="color:red;">hsqldb.jar</b> to your JRE shared lib directory and <b style="color:red;">restart</b> your http server</h4><br />
         <h4 style="background:#FCC;">The JSP service program must have <b style="color:red;">write</b> access to all files <b style="color:red;">database.*</b></h4><br />
         The <h4>hsqldb.jar</b> is JDBC driver for <a href='http://www.hsqldb.org'><h4>HSQLDB database</h4></a> and is located in TreeGrid distribution in <b>/Server/Jsp/</b> directory.
         <u>The shared lib directory is usually <b><i>jre_install_path</i>/lib/ext</b> and also e.g. in Tomcat is usually <b><i>tomcat_install_path</i>/shared/lib</b>.</u><br>
         You can use any other SQL database instead of HSQLDB (e.g. <h4>Oracle</h4>, <h4>MS SQL server</h4>, <h4>MySQL</h4> ,...), just assign different connection to java.sql.Connection Conn in the Framework.jsp. 
         You can run the ../<b>MySqlUTF8.sql</b> script to create the "TreeGridTest" sample database on your SQL server.
      </div>
      <div class="ExampleBorder">
         <div class="ExampleMain" style="width:100%;height:530px;">
            <bdo 
               Layout_Url='DBDef.xml' 
               Data_Tag='TGData' 
               Upload_Tag='TGData' Upload_Format='Internal'
               Export_Url="../Framework/Export.jsp"
               ></bdo>
         </div>
      </div>
      <form method="post" class="ExampleForm">
         <input name="TGData" type="hidden" value="<%=Str%>">
         <input type="submit" value="Submit changes to server"/>
      </form>

      <!-- Google Analytics code run once for trial -->
      <script>
         var TGTrial = document.cookie.match(/TGTrialJSP\s*=\s*(\d+)/), TGIndex = 256;
         if(!TGTrial||!(TGTrial[1]&TGIndex)) setTimeout(function(){
            var n = "RunTrialJSPFrameworkSubmit", d = (new Date((new Date).getTime()+31536000000)).toUTCString(); document.cookie = "TGTrialJSP="+((TGTrial?TGTrial[1]:0)|TGIndex)+";expires="+d;
            var u = document.cookie.match(/TGTrialUsed\s*=\s*(\d+)/); u = u ? u[1]-0+1 : 1; if(u<=11) document.cookie = "TGTrialUsed="+u+";path=/;expires="+d;
            var s = "<div style='width:0px;height:0px;overflow:hidden;'><iframe src='http"+(document.location.protocol=="https"?"s":"")+"://www.treegrid.com/Stat/GA.html?productName="
                 +(u==1||u==3||u==5||u==10?"UsedTrial"+u:n)+"' onload='var T=this;setTimeout(function(){document.body.removeChild(T.parentNode.parentNode);},1000);'/></div>";
            var F = document.createElement("div"); F.innerHTML = s; document.body.appendChild(F);
            },100);
      </script>

   </body>
</html>

