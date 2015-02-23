//+------------------------------------------------------------------+
//|                                                    FractalEA.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


extern int MovingAverage=100;

extern int RSIPeriod=14;
extern int BollingerPeriod=20;
extern int BollingerDeviation=2;

extern int Fast_Ema_Period = 12;
extern int Slow_Ema_Period = 26;
extern int Signal_Period = 9;
extern double BuyOrderTrigger = -0.0001;
extern double SellOrderTrigger = 0.0001;
extern double VolumE = 1000;

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
double Magic = 12121;

int  MaShift=0;
int  MaMethod=1;
int  MaAppliedTo=0;

int  MaShift2=0;
int  MaMethod2=1;
int  MaAppliedTo2=0;


int mode=0;


int init()
  {
      double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(ticksize == 0.00001 || ticksize == 0.001)
      pips = ticksize*10;
      else pips  = ticksize;
      return(0);

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
   double BuyDCFractal = iFractals(NULL,0,MODE_UPPER,0);
   double SellDCFractal = iFractals(NULL,0,MODE_LOWER,0);
   
   double BuyRSI = iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,0);
   double SellRSI = iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,0);
   
   double MidMovingAverage = iMA(NULL,0,MovingAverage,MaShift,MaMethod,MaAppliedTo,0);
   
   double MACD = iMACD(NULL,0,Fast_Ema_Period,Slow_Ema_Period,Signal_Period,MODE_CLOSE,MODE_MAIN,0);
   
   double SAR = iSAR(NULL,0,ParabolicStep,ParabolicMax,0);
   double PSAR = iSAR(NULL,0,ParabolicStep,ParabolicMax,1);
      
   
   
   if(High[0]>SAR&&Low[1]<PSAR)
   {
      
       int Bticket = OrderEntry(1);
       if(Low[0]<SAR&&High[1]>PSAR)
       if(OpenOrdersThisPair(Symbol())>=1)OrderExit(Bticket);
      
   }
   
   
   
   if(Low[0]<SAR&&High[1]>PSAR)
   {
        
       int Sticket = OrderEntry(0);
       if(High[0]>SAR&&Low[1]<PSAR)
       if(OpenOrdersThisPair(Symbol())>=1)OrderExit(Sticket);
      
   }
  
   

}

void OrderExit(int ticket)
{
   OrderDelete(ticket,CLR_NONE);
}



int OrderEntry(int direction)
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
               return(buyticket);
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
         return (sellticket);
   

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

