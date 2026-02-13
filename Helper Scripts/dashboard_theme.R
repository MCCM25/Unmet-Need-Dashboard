# Helper script - bslib styling 

dashboard_theme <- function(){

bslib::bs_theme(
  bootswatch = "flatly",
  bg = "#f3f3f3",
  fg = "black",
  primary = "#c3002f"
) %>% 
  bs_add_rules("
  
  /* remove padding around panel to maximise page area */
  body, .page-fillable {
    margin: 0 !important;
    padding: 0 !important;
    width: 100%;
    height: 100%;
  }
  
  /* ensure tab content fills page */
  .tab-content {
    padding: 0 !important;
    margin: 0 !important;
  }
  
  /* remove inner container spacing */
  .container-fluid, .bs-container {
    padding: 0 !important;
    margin: 0 !important;
    width: 100%;
  }
  

  /* header container */
  .header-bar {
    background-color: #003a60;
    border-bottom: 8px solid #c3002f !important;
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    font-size: 1.5rem;
    font-weight: bold;
    color: #fcdb03;
    }
   
  /* Left Side header (to position simulated data message + title) */
  .header-left {
    display: flex;
    align-items: center;
  }

  /* IS logo LHS */
  .logo-is {
    height: 60px;
    margin-left: 5%;
  }

  /* space between IS logo and title */
  .logo-spacer {
    flex-basis: 10%;
  }

  /*  title text */
  .header-title {
    font-size: 4.0rem;
    margin-left: 50%;
    white-space: nowrap;
    font-weight: bold;
    color: white;
  }

  /* WLC logo - RHS */
  .logo-wlc {
    height: 141px;
  }
    
    body { /* Add border to main body of app */
      border: 2px solid #003a60;
      margin: 1px;
      padding: 1px;
      overflow-y: hidden;
    } 
    
    .nav-link { /* Change nav_panel names colour to black */
      color: black !important;
    }
    
    .sidebar { /* style and theme side bar */
      padding: 5px;
      margin-right: 10px;
      border-radius: 10px;
      background-color: #f8f9fa;
    }
    
    
.coverpage_layout {
  margin: 20px 0;
  padding: 30px;
  background: #f3f3f3;
  border-radius: 16px;
  box-shadow: 0 6px 24px rgba(0,0,0,0.08);
}


    
    
    .guidance-video { /* add border to embedded guidance video */
      border: 3px solid #003a60;
      border-radius: 8px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    
    
    .video_wrapper {
  width: 100%;
  aspect-ratio: 16 / 9;
  margin-top: 15px;
}

.video_wrapper iframe {
  width: 100%;
  height: 100%;
  border: 3px solid #003a60;
  border-radius: 6px;
}

    
    
    .cover_section {
  background: white;
  padding: 18px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.06);
  margin-bottom: 20px;
}

 .cover_section .btn {
  width: 100%;
  margin-top: 10px;
}
   
    
      .card { /* put border in IS blue around maps in DZ Summary and CoT panels */
      border: 2px solid #003a60;
      border-radius: 10px;
      box-shadow: 4px 4px 12px rgba(0,0,0,0.2);
      overflow: hidden; 

      }
      
      #map { /* round map coners to match border corners */
      border-radius: 10px;
      }
      
      #panel_map_dz_summ { /* define panel height on DZ Summary tab to allow map to display */
      height: 72vh;
      }
      
    
    .card-body { /* Ensure map utilises full space within card border */
      padding:0; 
    }
    
  
    .selectize-control .selectize-input { /* IS blue border around year selectInput */
      border: 2px solid #003a60 !important;
      box-shadow: none !important;
    }
    
     .dropdown { /* IS blue border around dropdown selectize inputs */
      border: 2px solid #003a60 !important;
      box-shadow: none !important;
     }
     
   
    .plotlyOutput { /* border around  Change over time plotlyOutput */
    border: 2px solid #003a60;
    padding: 1px;
    border-radius: 8px;
    height: 100%;
    
    }
    
    #line_graph { /* round plotlyOutput corners to fit neatly inside border */
    border-radius: 8px;
    }
    
  
    
    .page-title { /* format title for methodology pages */
      text-align: center;
      font-size: 30px;
      font-weight: bold;
      margin-top: 15px;
      margin-bottom: 20px;
    
    }
    
    
    /* page number format and colouring */  
    .dataTables_wrapper .dataTables_paginate a,
    .dataTables_wrapper .dataTables_paginate span {
      color: #003a60 !important;
      background-color: #dee2e6 !important;
      
    }
    
    table.dataTable td {
      white-space: normal !important;    /* styling and formatting for Methodology table */
      vertical-align: top;
      line-height: 1.5;
      padding-top: 6px;
      padding-bottom: 6px;
    }
    
    
    table.dataTable td p {          /* paragraph spacing for Methodology table */
      margin-bottom: 10px;
    }
    
    /* pop up styling */
        .leaflet-popup-tip,
    .leaflet-popup-content-wrapper {
      border: 2px solid #003a60 !important;
    }
    
    /* style leaflet legend values */
    div.info.legend.leaflet-control i {
      border: 1.25px solid #003a60 !important;
    }
    
  .methodology_container { /* ensure methodology content fits page */
   height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
}

   
  ")

}
