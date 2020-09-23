//+------------------------------------------------------------------+
//|                                                TradeExecutor.mq4 |
//|                                      Copyright 2020, Lenny Kioko |
//|                                    https://lennykioko.github.io/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lenny Kioko"
#property link      "https://lennykioko.github.io/"
#property version   "1.00"
#property strict
#property show_inputs

enum e_orderType{
 Buy=1,
 Sell=2,
 BuyStop = 3,
 SellStop = 4,
};

input e_orderType  orderType = Buy;

extern double accountSize = 1000;
extern double percentageRisk = 1.0;

double riskPerTradeDollars = (accountSize * (percentageRisk / 100));

extern double pendingOrderPrice = 0.0;

extern double stopLossPrice = 0.0;
extern double takeProfitPrice = 0.0;

double magicNB = 5744;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
{
  if(IsTradingAllowed())
  {
    // buy
    if(orderType == 1 && pendingOrderPrice == 0.0)
    {
        double entryPrice = Ask;
        double lotSize = CalculateLotSize(riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(Symbol(), OP_BUY, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
    }

    // sell
    if(orderType == 2 && pendingOrderPrice == 0.0)
    {
        double entryPrice = Bid;
        double lotSize = CalculateLotSize(riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(Symbol(), OP_SELL, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
    }

    // buystop
    if(orderType == 3)
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(Symbol(), OP_BUYSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
    }

    // sellstop
    if(orderType == 4)
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(Symbol(), OP_SELLSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
    }
  }
}

//+------------------------------------------------------------------+

// custom re-usable functions

// works for fx pairs, may not work for indices
double GetPipValue()
{
  if(_Digits >= 4)
  {
    return 0.0001;
  }
  else
  {
    return 0.01;
  }
}

double CalculateLotSize(double riskDollars, double entryPrice, double slPrice)
{
  double pipValue = MarketInfo(Symbol(), MODE_TICKVALUE) * 10;
  double pips = MathAbs(entryPrice - slPrice) / GetPipValue();
  double div = pips * pipValue;
  double lot = NormalizeDouble(riskDollars / div, 2);

  return lot;
}

bool IsTradingAllowed()
{
  if(!IsTradeAllowed())
  {
    Alert("Expert Advisor is NOT Allowed to Trade. Check AutoTrading.");
    return false;
  }

  if(!IsTradeAllowed(Symbol(), TimeCurrent()))
  {
    Alert("Trading NOT Allowed for specific Symbol and Time");
    return false;
  }
  return true;
}
