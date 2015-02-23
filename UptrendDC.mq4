//+------------------------------------------------------------------+
//|                                                      Volumes.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 5
#property indicator_color1  Black
#property indicator_color2  Green
#property indicator_color3  Red
#property indicator_width2  2
#property indicator_width3  2

extern double DirectionalChange1=0.005;
extern double DirectionalChange2=0.01;
extern double DirectionalChange3=0.025;
extern double DirectionalChange4=0.05;



extern int LookBackLambda = 1;
//---- indicator buffers
double ExtVolumesBuffer[];
double ExtDCFirstBuffer[];
double ExtDCSecondBuffer[];
double ExtDCThirdBuffer[];
double ExtDCFourthBuffer[];

double DCdefault = 40;
double DCSetValue1= 100;
double DCSetValue2= 200;
double DCSetValue3= 100;
double DCSetValue4= 200;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtVolumesBuffer);       
   SetIndexBuffer(1,ExtDCFirstBuffer);
   SetIndexBuffer(2,ExtDCSecondBuffer);
   SetIndexBuffer(3,ExtDCThirdBuffer);
   SetIndexBuffer(4,ExtDCFourthBuffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2,Blue);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2,Blue);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,2,Blue);
   SetIndexStyle(4,DRAW_HISTOGRAM,0,2,Blue);
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("DC");
   SetIndexLabel(0,"Directional Change");      
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
//---- sets drawing line empty value
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);   
   SetIndexEmptyValue(3,0.0); 
   SetIndexEmptyValue(4,0.0);
   
   SetLevelValue(1,100);
   SetLevelValue(2,200);
   SetLevelValue(3,300);
   SetLevelValue(4,400);     
//---- initialization done

   
   return(0);
  }
//+------------------------------------------------------------------+
//| Volumes                                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit,nCountedBars;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars;
//----
   for(i=0; i<nLimit; i++)
     {
      double dVolume=Volume[i];
      double BuyLambda = ((Close[i]-Open[i])/Open[i])*100;
      
      
      
       if(BuyLambda < DirectionalChange1)
         {
          ExtVolumesBuffer[i]=500;
          ExtDCFirstBuffer[i]=50;
          ExtDCSecondBuffer[i]=0.0;
          ExtDCThirdBuffer[i]=0.0;
          ExtDCFourthBuffer[i]=0.0;       
         }
      
      if(BuyLambda > DirectionalChange1)
        {
         ExtVolumesBuffer[i]=500;
         ExtDCFirstBuffer[i]=100;
         ExtDCSecondBuffer[i]=0.0;
         ExtDCThirdBuffer[i]=0.0;
         ExtDCFourthBuffer[i]=0.0;       
        }
      
      if(BuyLambda > DirectionalChange2 && BuyLambda > DirectionalChange1)
        {
         ExtVolumesBuffer[i]=500;
         ExtDCFirstBuffer[i]=0.0;
         ExtDCSecondBuffer[i]=200;
         ExtDCThirdBuffer[i]=0.0;
         ExtDCFourthBuffer[i]=0.0;        
        } 
      
      
      if(BuyLambda > DirectionalChange3 && BuyLambda > DirectionalChange2 && BuyLambda > DirectionalChange1)
        {
         ExtVolumesBuffer[i]=500;
         ExtDCFirstBuffer[i]=0.0;
         ExtDCSecondBuffer[i]=0.0;
         ExtDCThirdBuffer[i]=300;
         ExtDCFourthBuffer[i]=0.0;        
        } 
      
      if(BuyLambda > DirectionalChange4 && BuyLambda > DirectionalChange3 && BuyLambda > DirectionalChange2 && BuyLambda > DirectionalChange1)
        {
         ExtVolumesBuffer[i]=500;
         ExtDCFirstBuffer[i]=0.0;
         ExtDCSecondBuffer[i]=0.0;
         ExtDCThirdBuffer[i]=0.0;
         ExtDCFourthBuffer[i]=400;        
        } 
     }        
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

