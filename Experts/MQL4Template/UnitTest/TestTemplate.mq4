//+------------------------------------------------------------------+
//|                                             TestGetOrderLots.mq4 |
//|                                 Copyright 2018, Keisuke Iwabuchi |
//|                  https://github.com/KeisukeIwabuchi/MQL4Template |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Keisuke Iwabuchi"
#property link      "https://github.com/KeisukeIwabuchi/MQL4Template"
#property version   "1.00"
#property strict


#include <MQL4Template\UnitTest.mqh>
#include <MQL4Template\Template_1.09.mqh>


class TemplateTest : public UnitTest
{
public:
    void TestGetOrderLots(void);
    void TestGetOrderCount(void);
    void TestNormalizeLots(void);
    void TestTradeTypeToString(void);
    void TestPipsToPrice(void);
    void TestPipsToPoint(void);
    void TestGetSymbolEndingOfWord(void);
};


void TemplateTest::TestGetOrderLots(void)
{
    this.Init("TestGetOrderLots");

    // OP_BUYポジションのロット数
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_BUY, 112233));
    // OP_BUYポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_BUY, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLポジションのロット数
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_SELL, 112233));
    // OP_SELLポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_SELL, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_BUYLIMITポジションのロット数
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_BUYLIMIT, 112233));
    // OP_BUYLIMITポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_BUYLIMIT, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLLIMITポジションのロット数
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_SELLLIMIT, 112233));
    // OP_SELLLIMITポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_SELLLIMIT, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_BUYSTOPポジションのロット数
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_BUYSTOP, 112233));
    // OP_BUYSTOPポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_BUYSTOP, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLSTOPポジションのロット数
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OP_SELLSTOP, 112233));
    // OP_SELLSTOPポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.2, GetOrderLots(OP_SELLSTOP, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OPEN_POS, ALL_POS, PEND_POSの3種を買いでテスト, 両建て不可口座対策で買いと分けてる
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OPEN_POS, 112233));
    this.AssertEqualsWithDigits(0.3, GetOrderLots(ALL_POS, 112233), 1);
    this.AssertEquals(0.2, GetOrderLots(PEND_POS, 112233));
    this.ResetOrder();
    
    // OPEN_POS, ALL_POS, PEND_POSの3種を売りでテスト, 両建て不可口座対策で買いと分けてる
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(0.1, GetOrderLots(OPEN_POS, 112233));
    this.AssertEqualsWithDigits(0.3, GetOrderLots(ALL_POS, 112233), 1);
    this.AssertEquals(0.2, GetOrderLots(PEND_POS, 112233));
    this.ResetOrder();
}


void TemplateTest::TestGetOrderCount(void)
{
    this.Init("TestGetOrderLots");

    // OP_BUYポジションのロット数
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_BUY, 112233));
    // OP_BUYポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_BUY, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLポジションのロット数
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_SELL, 112233));
    // OP_SELLポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_SELL, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_BUYLIMITポジションのロット数
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_BUYLIMIT, 112233));
    // OP_BUYLIMITポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_BUYLIMIT, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLLIMITポジションのロット数
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_SELLLIMIT, 112233));
    // OP_SELLLIMITポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_SELLLIMIT, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_BUYSTOPポジションのロット数
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_BUYSTOP, 112233));
    // OP_BUYSTOPポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_BUYSTOP, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OP_SELLSTOPポジションのロット数
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OP_SELLSTOP, 112233));
    // OP_SELLSTOPポジション複数時のロット数
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(2, GetOrderCount(OP_SELLSTOP, 112233));
    // 一旦ポジション決済(両建て不可口座でのテスト対策)
    this.ResetOrder();
    
    // OPEN_POS, ALL_POS, PEND_POSの3種を買いでテスト, 両建て不可口座対策で買いと分けてる
    this.MakeOrder(Symbol(), OP_BUY, 0.1, Ask, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_BUYLIMIT, 0.1, Ask - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_BUYSTOP, 0.1, Ask + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OPEN_POS, 112233));
    this.AssertEquals(3, GetOrderCount(ALL_POS, 112233));
    this.AssertEquals(2, GetOrderCount(PEND_POS, 112233));
    this.ResetOrder();
    
    // OPEN_POS, ALL_POS, PEND_POSの3種を売りでテスト, 両建て不可口座対策で買いと分けてる
    this.MakeOrder(Symbol(), OP_SELL, 0.1, Bid, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_SELLLIMIT, 0.1, Bid + 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.MakeOrder(Symbol(), OP_SELLSTOP, 0.1, Bid - 100 * _Point, 0, 0, "TestGetOrderLots", 112233);
    this.AssertEquals(1, GetOrderCount(OPEN_POS, 112233));
    this.AssertEquals(3, GetOrderCount(ALL_POS, 112233));
    this.AssertEquals(2, GetOrderCount(PEND_POS, 112233));
    this.ResetOrder();
}


void TemplateTest::TestNormalizeLots(void)
{
    this.Init("TestNormalizeLots");
    
    // 2桁で丸められること
    this.AssertEquals(0.1, NormalizeLots(0.1));
    this.AssertEquals(0.01, NormalizeLots(0.01));
    this.AssertEquals(0.01, NormalizeLots(0.011));
    this.AssertEquals(0.02, NormalizeLots(0.016));
    this.AssertEquals(0.01, NormalizeLots(0.011, "USDJPY"));
    this.AssertEquals(0.01, NormalizeLots(0.011, "EURUSD"));
    
    // 最小取引ロット未満のロット数では最小取引ロットを返す
    this.AssertEquals(MarketInfo(Symbol(), MODE_MINLOT), NormalizeLots(0));
    this.AssertEquals(MarketInfo("USDJPY", MODE_MINLOT), NormalizeLots(0, "USDJPY"));
    this.AssertEquals(MarketInfo("EURUSD", MODE_MINLOT), NormalizeLots(0, "EURUSD"));
    
    // 最大取引ロット未満のロット数では最大取引ロットを返す
    this.AssertEquals(MarketInfo(Symbol(), MODE_MAXLOT), NormalizeLots(100000));
    this.AssertEquals(MarketInfo("USDJPY", MODE_MAXLOT), NormalizeLots(100000, "USDJPY"));
    this.AssertEquals(MarketInfo("EURUSD", MODE_MINLOT), NormalizeLots(0, "EURUSD"));
}


void TemplateTest::TestTradeTypeToString(void)
{
    this.Init("TestTradeTypeToString");
    
    this.AssertEquals("OP_BUY", TradeTypeToString(OP_BUY));
    this.AssertEquals("OP_SELL", TradeTypeToString(OP_SELL));
    this.AssertEquals("OP_BUYLIMIT", TradeTypeToString(OP_BUYLIMIT));
    this.AssertEquals("OP_SELLLIMIT", TradeTypeToString(OP_SELLLIMIT));
    this.AssertEquals("OP_BUYSTOP", TradeTypeToString(OP_BUYSTOP));
    this.AssertEquals("OP_SELLSTOP", TradeTypeToString(OP_SELLSTOP));
    this.AssertEquals("Invalid value", TradeTypeToString(-1));
    this.AssertEquals("Invalid value", TradeTypeToString(6));
}


void TemplateTest::TestPipsToPrice(void)
{
    this.Init("TestPipsToPrice");
    
    mql4.SetSymbol("USDJPY");
    this.AssertEquals(1.0, PipsToPrice(100));
    this.AssertEquals(0.0, PipsToPrice(0));
    
    mql4.SetSymbol("EURUSD");
    this.AssertEquals(0.01, PipsToPrice(100));
    this.AssertEquals(0.0, PipsToPrice(0));
    
    mql4.SetSymbol(Symbol());
}


void TemplateTest::TestPipsToPoint(void)
{
    this.Init("TestPipsToPoint");
    
    this.AssertEquals(1000, PipsToPoint(100));
    this.AssertEquals(0, PipsToPoint(0));
    this.AssertEquals(1, PipsToPoint(0.1));
}


void TemplateTest::TestGetSymbolEndingOfWord(void)
{
    this.Init("TestGetSymbolEndingOfWord");
    
    mql4.SetSymbol("EURUSD");
    this.AssertEquals("", GetSymbolEndingOfWord());
    
    mql4.SetSymbol("EURUSDpro");
    this.AssertEquals("pro", GetSymbolEndingOfWord());
    
    mql4.SetSymbol("EURUSD.");
    this.AssertEquals(".", GetSymbolEndingOfWord());
    
    mql4.SetSymbol("NK225");
    this.AssertEquals("", GetSymbolEndingOfWord());
    
    mql4.SetSymbol(Symbol());
}


TemplateTest *test;


int OnInit()
{
    mql4 = new MQL4();
    test = new TemplateTest();

    //test.TestGetOrderLots();
    //test.TestGetOrderCount();
    //test.TestNormalizeLots();
    //test.TestTradeTypeToString();
    //test.TestPipsToPrice();
    //test.TestPipsToPoint();
    test.TestGetSymbolEndingOfWord();

    test.Result();

    return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
    delete test;
    delete mql4;
}


void OnTick()
{
    
}

