//+------------------------------------------------------------------+
//|                                                    FractalEA.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern double DirectionalChange=0.005;
extern int LookBackLambda = 1;
extern double DailyDirectionalChange=2;
extern int DailyLookBackLambda=50;

int FastMovingAverage=14;
int SlowMovingAverage=42;  

extern int BollingerPeriod=20;
extern int BollingerPeriod2=100;
extern int BollingerDeviation=2;
extern int BollingerPipsDiff=50;

extern int TakeProfit = 400;
extern int StopLoss = 100;

extern bool UseTrailingStop = false;
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

int BUY_trademode=0;
int SELL_trademode=0;

int ProxySellTicket = 0;
int ProxyBuyTicket = 0;

double Size;

double ModeOFTrade = 0;


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
  
   AdjustingLotSize();
   
   if(OpenOrdersThisPair(Symbol())>=1) //if there are orders open in a currency, run the next two functions
   {
      if(UseTrailingStop)AdjustTrail();
   }
   if(IsNewCandle())Strategy();
  

   return(0);
  }

void AdjustingLotSize()
{
   if(LotSize>=0.01&&LotSize<=0.09)
   {
      Size=0.1;
   }
   if(LotSize>=0.1&&LotSize<=0.9)
   {
      Size=1;
   }
   if(LotSize>=1&&LotSize<=9)
   {
      Size=10;
   }
}



void Strategy()
{
   double BuyDCFractal = iFractals(NULL,0,MODE_UPPER,0);
   double SellDCFractal = iFractals(NULL,0,MODE_LOWER,0);

   double MiddleBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_MAIN,1);
   double MiddleBB2=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_MAIN,1);
   double MiddleBB3=iBands(NULL,PERIOD_H4,BollingerPeriod2,BollingerDeviation,0,0,MODE_MAIN,1);
   double LowerBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,1);
   double UpperBB=iBands(NULL,0,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,1);

   double SellLambda = ((Close[LookBackLambda]-Close[0])/Close[LookBackLambda])*100;
   double DailySellLambda = ((Close[100]-Close[0])/Close[100])*100; //TO DETECT UPTREND and DOWNDTREND
    
   double BuyLambda = ((Close[0]-Close[LookBackLambda])/Close[LookBackLambda])*100;
   double DailyBuyLambda = ((Close[0]-Close[100])/Close[100])*100; //TO DETECT UPTREND and DOWNDTREND
   
   double CurrentLambda = iClose(NULL,PERIOD_D1,0);
   double PrevLambda = iClose(NULL,PERIOD_D1,DailyLookBackLambda);
   
   double DailyLambdaBUY = ((CurrentLambda-PrevLambda)/PrevLambda)*100;
   double DailyLambdaSELL = ((PrevLambda-CurrentLambda)/PrevLambda)*100;
   
   if(DailyLambdaBUY>DailyDirectionalChange)
   {
      ModeOFTrade = 1; 
   }
   
   if(DailyLambdaSELL>DailyDirectionalChange)
   {  
      ModeOFTrade = -1; //
   }
    
   
   
   int PrevTrade = LastTrade();
   double BBDifference = (UpperBB-LowerBB)/pips;
   
   
         if(BuyLambda>DirectionalChange&&Close[0]<MiddleBB&&BBDifference>BollingerPipsDiff&&Close[0]<MiddleBB3&&ModeOFTrade==-1)//-1 when Currency is highly Volatile.. 1 when Curr is low volatility(Observation) EUR/USD 198 with -1, EUR/GBP 66 with 1
         {
        
            if(SELL_trademode==1)
            {  
                int SellExit=2;
                OrderExit(ProxySellTicket,SellExit);
            }
            int buyticket = OrderEntry(0);
            double free=AccountFreeMargin();
            double exposure = ((StopLoss*Size)/AccountBalance());
            Comment("Account free margin is ",DoubleToStr(free,2),"\n","Current time is ",TimeToStr(TimeCurrent()),"\n","Exposure",DoubleToStr(exposure,5));
            ProxyBuyTicket = buyticket;
            SELL_trademode=0;
         
         }
    
     
   
         if(SellLambda>DirectionalChange&&Close[0]>MiddleBB&&BBDifference>BollingerPipsDiff&&Close[0]>MiddleBB3&&ModeOFTrade==1)
         {
            if(BUY_trademode==1)
            {
               int BuyExit=1;
               OrderExit(ProxyBuyTicket,BuyExit);
            }
         
            int sellticket = OrderEntry(1);
            double free2=AccountFreeMargin();
            double exposure2 = ((StopLoss*Size)/AccountBalance());
            Comment("Account free margin is ",DoubleToStr(free2,2),"\n","Current time is ",TimeToStr(TimeCurrent()),"\n","Exposure",DoubleToStr(exposure2,5));
            ProxySellTicket = sellticket;
            BUY_trademode=0;
         
         }

     
}


void OrderExit(int ticket,int trademode)
{
     if(trademode==1)
     {
         OrderClose(ticket,LotSize,Ask,0,Red);
     
     }
       if(trademode==2)
    {
         OrderClose(ticket,LotSize,Ask,0,Red);
   
         
    }
    
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
                  BUY_trademode=1;
                     return (buyticket);
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
                  SELL_trademode=1;
                     return(sellticket);
   

   }
            

   
}

int LastTrade()
{  
   int total = OrdersHistoryTotal();
   
   if(OrderSelect(total,total,MODE_HISTORY))
   {
        if(OrderMagicNumber()==Magic)
           if(OrderSymbol()==Symbol())
              if(OrderType()==OP_BUY)
              {
                  int LastOrder = OrderType();
                  return (LastOrder);
          
              }
              if (OrderType()==OP_SELL)
              {
                  int LastOrder2 = OrderType();
                  return (LastOrder2);
              }
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

