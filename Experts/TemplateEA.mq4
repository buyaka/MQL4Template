// #property copyright ""
// #property link      ""
#property strict
#property version   "1.00"


#define TRADE_RETRY 0


#include <Template_1.04.mqh>


sinput double Lots              = 0.1;   // 取引数量
sinput int    MagicNumber       = 123;   // マジックナンバー
input  double TP                = 100;   // 利食い(pips)
input  double SL                = 100;   // 損切り(pips)
sinput double Slippage          = 1.0;   // スリッページ(pips)


int  TradeBar = 0;
int  Mult = 10;
bool IsTrade = true;


int OnInit()
{
   TradeBar = Bars;
   Mult = (Digits == 3 || Digits == 5) ? 10 : 1;
   
   HideTestIndicators(true);

   return(INIT_SUCCEEDED);
}


void OnTick()
{
   double pos = getOrderLots(OPEN_POS, MagicNumber);

   if (pos == 0 && IsTrade) {
      int    entry_signal = getEntrySignal();
      int    trade_type   = -1;
      double trade_price  = 0;
      
      if (entry_signal == 1) {
         trade_type = OP_BUY;
         trade_price = Ask;
      } else if (entry_signal == -1) {
         trade_type = OP_SELL;
         trade_price = Bid;
      }
      
      if (trade_type >= 0 && TradeBar != Bars) {
         int trade_result = 
            EntryWithPips(trade_type, Lots, trade_price, Slippage, SL, TP, COMMENT, MagicNumber);
         
         if (trade_result == 0) {
            TradeBar = Bars;
         } else {
            if (TRADE_RETRY == 0) {
               TradeBar = Bars;
            }
            if (trade_result == 134 && IsTesting()) {
               IsTrade = false;
            }
         }
      }
   } else {
      bool exit_signal = getExitSignal();
      
      if (exit_signal) {
         Exit(Slippage, MagicNumber);
      }
   }
}


void OnDeinit(const int reason)
{
   Comment("");
}


int getEntrySignal()
{
   return(0);
}


bool getExitSignal()
{
   return(false);
}
