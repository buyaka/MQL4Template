#property strict
#property version   "1.00"


#include <Template.mqh>


extern double Lots        = 0.1; // 取引数量
extern int    MagicNumber = 123; // ロット数
extern double TP          = 100; // 損切り(pips)
extern double SL          = 100; // 利食い(pips)
extern double Slippage    = 1.0; // スリッページ(pips)


int TradeBar = 0;
int Mult = 10;


int OnInit()
{
   TradeBar = Bars;
   Mult = (Digits == 3 || Digits == 5) ? 10 : 1;

   return(INIT_SUCCEEDED);
}


void OnTick()
{
   double lots = Lots;
   double pos = getOrderLots(OPEN_POS, MagicNumber);

   if (pos == 0) {
      int entry_signal = getEntrySignal();
      
      if (entry_signal == 1 && TradeBar != Bars) {
         if (lots == 0) {
            lots = Lots;
         }
         if (EntrySL(OP_BUY, lots, Ask, Slippage, SL, TP, COMMENT, MagicNumber)) {
            TradeBar = Bars;
         }
      }
      if (entry_signal == -1 && TradeBar != Bars) {
         if (lots == 0) {
            lots = Lots;
         }
         if (EntrySL(OP_SELL, lots, Bid, Slippage, SL, TP, COMMENT, MagicNumber)) {
            TradeBar = Bars;
         }
      }
   } else {
      bool exit_signal = getExitSignal();
      
      if (exit_signal == 1) {
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


int getExitSignal()
{
   return(0);
}
