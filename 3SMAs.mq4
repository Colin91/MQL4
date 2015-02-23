//+------------------------------------------------------------------+
//|                                                    FractalEA.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int FASTMovingAverage_0=7;
extern int MIDMovingAverage_0=14;
extern int SLOWMovingAverage_0=100;

extern int Fast_Ema_Period = 12;
extern int Slow_Ema_Period = 26;
extern int Signal_Period = 9;

extern double ParabolicStep = 0.02;
extern double ParabolicMax = 0.2;

extern int TakeProfit = 50;
extern int StopLoss = 25;

extern bool UseTrailingStop = true;
extern int WhenToTrail = 100;
extern int TrailAmount = 50;
extern int CandlesBack = 10;

extern double LotSize=0.01;

double pips;
double Lots;
double Magic = 12121;

int  MaShift=0;
int  MaMethod=1;
int  MaAppliedTo=0;

int  MaShift2=0;
int  MaMethod2=1;
int  MaAppliedTo2=0;


int init()
  {
      double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(ticksize == 0.00001 || ticksize == 0.001)
      pips = ticksize*10;
      else pips  = ticksize;
      return(0);
      
      double Lot = MarketInfo(Symbol(),MODE_LOTSIZE);
            

  }

int deinit()
  {

   return(0);
  }

int start()
  {
   
   if(OpenOrdersThisPair(Symbol())>=1) //if there are orders open in a currency, run the next two functions
   {
      if(UseTrailingStop)AdjustTrail();
   }
   if(IsNewCandle())Strategy();
   

  

   return(0);
  }


void Strategy()
{
      
   double FASTMovingAverage = iMA(NULL,0,FASTMovingAverage_0,MaShift,MaMethod,MaAppliedTo,0);
   double MIDMovingAverage = iMA(NULL,0,MIDMovingAverage_0,MaShift,MaMethod,MaAppliedTo,0);
   
   double PrevFASTMovingAverage = iMA(NULL,0,FASTMovingAverage_0,MaShift,MaMethod,MaAppliedTo,2);
   double PrevMIDMovingAverage = iMA(NULL,0,MIDMovingAverage_0,MaShift,MaMethod,MaAppliedTo,2);
   
   double SLOWMovingAverage = iMA(NULL,0,SLOWMovingAverage_0,MaShift,MaMethod,MaAppliedTo,0);
   
   double MACD = iMACD(NULL,0,Fast_Ema_Period,Slow_Ema_Period,Signal_Period,MODE_CLOSE,MODE_MAIN,0);
   
   double SAR = iSAR(NULL,PERIOD_M15,ParabolicStep,ParabolicMax,0);
   double PSAR = iSAR(NULL,0,ParabolicStep,ParabolicMax,1);
   
   double ADX = iADX(NULL,PERIOD_H1,14,MODE_CLOSE,MODE_MAIN,0);
   
   if((FASTMovingAverage>MIDMovingAverage)&&(PrevFASTMovingAverage<PrevMIDMovingAverage)&&(FASTMovingAverage<SLOWMovingAverage))
      {
          OrderEntry(0);
      }
   
  
    if((FASTMovingAverage<MIDMovingAverage)&&(PrevFASTMovingAverage>PrevMIDMovingAverage)&&(FASTMovingAverage>SLOWMovingAverage))
      {
          OrderEntry(1); 
      }
   
   

}

void OrderEntry(int direction)
{
   if(direction==0)
   {
      if(StopLoss==0)double bsl=0;
      else bsl = Ask-(StopLoss*pips);
      if(TakeProfit==0)double btp=0;
      else btp = Ask+(TakeProfit*pips);

      if(OpenOrdersThisPair(Symbol()) == 0)
         int buyticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,0,0,NULL,Magic,0,Green); 
               if(buyticket>0)OrderModify(buyticket,OrderOpenPrice(),bsl,btp,0,CLR_NONE); 
               
   }
   
   if(direction==1)
   {
    
      if(StopLoss==0) double ssl=0;
      else ssl = Bid+(StopLoss*pips);
      if(TakeProfit==0)double stp=0;
      else stp = Bid-(TakeProfit*pips);

      if(OpenOrdersThisPair(Symbol()) == 0)
         int sellticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,0,0,NULL,Magic,0,Red);
         if(sellticket>0)OrderModify(sellticket,OrderOpenPrice(),ssl,stp,0,CLR_NONE); 
           

   }
            

   
}


void AdjustTrail()
{
   int buyStopCandle = iLowest(NULL,0,1,CandlesBack,1);
   int sellStopCandle = iHighest(NULL,0,2,CandlesBack,1);
   
   for(int b = OrdersTotal()-1;b>=0;b--)
   {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic)
            if(OrderSymbol()==Symbol())
               if(OrderType()==OP_BUY)
                  if(Bid-OrderOpenPrice()>WhenToTrail*pips) //if price moved 100pips,, start trailing stop
                     if(OrderStopLoss()<Bid-pips*TrailAmount)
                        OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(pips*TrailAmount),OrderTakeProfit(),0,CLR_NONE);
   }
   
   
   for(int s = OrdersTotal()-1;s>=0;s--)
   {
   
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
           if(OrderMagicNumber()==Magic)
              if(OrderSymbol()==Symbol())
                 if(OrderType()==OP_SELL)
                    if(OrderOpenPrice()-Ask>WhenToTrail*pips) //if price moved 100pips,, start trailing stop
                       if(OrderStopLoss()>Ask+TrailAmount*pips||OrderStopLoss()==0)
                          OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(TrailAmount*pips),OrderTakeProfit(),0,CLR_NONE);   
   
   }
   
}



bool IsNewCandle()
{
   static int  BarsOnChart = 1; 
   if(Bars == BarsOnChart) 
   return (false);          
   BarsOnChart = Bars; 
   return (true);

}


int OpenOrdersThisPair(string pair) 
{
    int total=0;
    for(int i=OrdersTotal()-1;i>=0;i--)
    { 
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==pair)
      total++;
    }
    return(total);     
         
}   

