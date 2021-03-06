"use strict";

// One link to sample, the links are generated in loop
Vue.component('sample-link', {
  props: ['link'],
  methods: {
      Click : function(Source,event,example){
         var item = event.target;
         if(TG.Reload(Source)){ 
            // Updates the HTML links to show information for shown example
            for(var t=item.parentNode.parentNode.firstElementChild;t;t=t.nextElementSibling) if(t.firstElementChild&&t.firstElementChild.className.indexOf('Active')!=-1) t.firstElementChild.className = t.firstElementChild.className.replace(/\s+Active/,'');
            item.className += ' Active';
            document.getElementById('LayoutLink').href = Source.Layout.Url; document.getElementById('LayoutName').innerHTML = Source.Layout.Url; 
            document.getElementById('DataLink').href = Source.Data.Url; document.getElementById('DataName').innerHTML = Source.Data.Url;
            document.getElementById('DataDesc').innerHTML = example=="Static" ? " (static JSON data)" : example=="Sheet" ? " (server script loads JSON data from file)" : " (server script generates JSON data from database)";
            }
         }
      },
  template: '<span><span v-on:click="Click(link.Source,$event,link.id);" :class="link.Active?\'Link Active\':\'Link\'">{{link.Text}}</span> ({{link.Comment?link.Comment:"SQL"}})</span>'
})

// Links to the examples, defines the data source to be reloaded to TreeGrid on link click
var SampleLinks = new Vue({
   el: '#SampleLinks',
   data: {
      Examples : {
         Static: { 
            id:'Static', Text: 'Static file', Active:1, Comment:'no upload', 
            Source:{
               Layout:{Url:'Layouts/StaticDef.js'}, 
               Data:{Url:'Layouts/StaticData.js'},
               ExportPDF:{Url:"http://localhost:8000/getpdf", Type:"Cfg,Def,Cols,All"}
               }
            },
         Table: { 
            id:'Table', Text:'Plain table', 
            Source:{
               Layout:{Url:'Layouts/TableDef.js'}, 
               Data:{Url:'http://localhost:8000/get?table=TableData&idcol=ID'},
               Upload:{Url:'http://localhost:8000/set?table=TableData&idcol=ID', Format:'JSON', Data:'Data'},
               ExportPDF:{Url:"http://localhost:8000/getpdf?data=get%3Ftable%3DTableData%26idcol%3DID", Type:"Cfg,Def,Cols,Fixed,Changes"}
               }
            },
         Tree: { 
            id:'Tree', Text:'Tree table',
            Source: {
               Layout:{Url:'Layouts/TreeDef.js'}, 
               Data:{Url:'http://localhost:8000/get?table=TreeData&idcol=id&parentcol=Parent&footid=%23Foot'},
               Upload:{Url:'http://localhost:8000/set?table=TreeData&idcol=id&parentcol=Parent&footid=%23Foot', Format:'JSON', Data:'Data'},
               ExportPDF:{Url:"http://localhost:8000/getpdf?data=get%3Ftable%3DTreeData%26idcol%3Did%26parentcol%3DParent%26footid%3D%2523Foot", Type:"Cfg,Def,Cols,Fixed,Changes"}
               }
            },
         GanttBasic: {
            id:'GanttBasic', Text:'Plain Gantt',
            Source: {
               Layout:{Url:'Layouts/GanttBasicDef.js'}, 
               Data:{Url:'http://localhost:8000/get?table=GanttBasic&idcol=id'},
               Upload:{Url:'http://localhost:8000/set?table=GanttBasic&idcol=id', Format:'JSON', Data:'Data'},
               ExportPDF:{Url:"http://localhost:8000/getpdf?data=get%3Ftable%3DGanttBasic%26idcol%3Did", Type:"Cfg,Def,Cols,Fixed,Changes"}
               }
            },
         GanttTree: { 
            id:'GanttTree', Text:'Gantt tree',
            Source: {
               Layout:{Url:'Layouts/GanttTreeDef.js'}, 
               Data:{Url:'http://localhost:8000/get?table=GanttTree&idcol=id'},
               Upload:{Url:'http://localhost:8000/set?table=GanttTree&idcol=id', Format:'JSON', Data:'Data'},
               ExportPDF:{Url:"http://localhost:8000/getpdf?data=get%3Ftable%3DGanttTree%26idcol%3Did", Type:"Cfg,Def,Cols,Fixed,Changes"}
               }
            },
         Run: { 
            id:'Run', Text:'Run chart',
            Source: {
               Layout:{Url:'Layouts/RunDef.js'}, 
               Data:{Url:'http://localhost:8000/get?table=Run&idcol=id'},
               Upload:{Url:'http://localhost:8000/set?table=Run&idcol=id', Format:'JSON', Data:'Data'},
               ExportPDF:{Url:"http://localhost:8000/getpdf?data=get%3Ftable%3DRun%26idcol%3Did", Type:"Cfg,Def,Cols,Fixed,Changes"}
               }
            },
         Sheet: { 
            id:'Sheet', Text:'Sheet',
            Source: {
               Layout:{Url:'Layouts/SheetDef.js'}, 
               Data:{Url:'http://localhost:8000/getfile?file=SheetData.js'},
               Upload:{Url:'http://localhost:8000/setfile?file=SheetData.js', Format:'JSON', Data:'Data', Type:'Body,AutoCols,Focused'},
               ExportPDF:{Url:"http://localhost:8000/getpdf", Type:"Cfg,Def,Cols,All"}
               }
            }
         }
      }
   })

// Creates TreeGrid dynamically by TreeGrid function and links it to the Vue component
var TG = new Vue({
   el:"#TreeGridMainTag",
   data: {
      Grid: null // Reference to created TreeGrid object
      },
   methods: {
      Reload: function(Source){ return this.Grid.Reload(Source); }, // Reloads TreeGrid data from new source. Can be avoided and called directly TG.Grid.Reload(Source); or Grids.SampleGrid.Reload(Source);

      // Custom method to demonstrate calling Vue method from TreeGrid code
      // Called from TreeGrid json layout, from Action OnRightClickCell, except Sheet example
      // Shows simple custom menu and calls some basic TreeGrid API methods on menu item click
      showCustomMenu : function(row,col) {
         var G = this.Grid;
         this.Grid.ShowMenu(row,col,{Items:[
            { Name:row.Deleted?"Undelete row":"Delete row",OnClick:function(){ G.DeleteRow(row,row.Deleted?3:1); } },
            { Name:row.Selected?"Deselect row":"Select row",OnClick:function(){ G.SelectRow(row); } },
            { Name:"Copy row",OnClick:function(){ G.CopyRow(row,null,row,1,0); } },
            { Name:"Add new row",OnClick:function(){ G.AddRow(null,row,1); } }
            ]});
         return 1;
         }
      },
   created: function () {
      // Handles loading error
      TGSetEvent("OnLoadError","SampleGrid",function(grid){ alert("TreeGrid cannot load!\nCheck if the NodeJS server runs on the url http://localhost:8000\nThe sample NodeJS server is located in /ExamplesNode/Server"); });
      },

   mounted: function() {
      // Creates TreeGrid dynamically. By the id value the grid will be accessible for global API like Grids.SampleGrid.Reload();
      // Links the Vue component to the created grid as Grid.Component and the grid to Vue component by the this.Grid
      this.Grid = TreeGrid(
         { 
         Debug:'check', id:'SampleGrid', 
         Layout: { Url:"Layouts/StaticDef.js" }, 
         Data: { Url:"Layouts/StaticData.js" },
         ExportPDF:{Url:"http://localhost:8000/getpdf", Type:"Cfg,Def,Cols,All"}
         },
         this.$el,
         { Component:this }
         );
      },
   destroyed: function(){
      this.Grid.Dispose();
      }
   });