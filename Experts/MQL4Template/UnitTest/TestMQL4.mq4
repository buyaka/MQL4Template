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
#include <MQL4Template\MQL4.mqh>


class MQL4Test : public UnitTest
{
private:
    MQL4 *mql4;

public:
    void TestGetSymbol(void);
    void TestGetPoint(void);
    void TestGetDigits(void);
    void TestGetTradeBar(void);
    void TestGetMult(void);
    void TestGetIsTrade(void);
    void TestGetGMTShift(void);
    void TestGetIsBuyTrade(void);
    void TestGetIsSellTrade(void);
};


void MQL4Test::TestGetSymbol(void)
{
    this.Init("TestGetSymbol");
    
    mql4 = new MQL4();
    
    // デフォルトはチャートの通貨ペアとなる
    this.AssertEquals(_Symbol, mql4.GetSymbol());
    
    // SetSymbolメソッドを使用した場合はその通貨ペアとなる
    mql4.SetSymbol("USDJPY");
    this.AssertEquals("USDJPY", mql4.GetSymbol());
    
    // 空文字はセット不可
    mql4.SetSymbol("USDJPY");
    mql4.SetSymbol("");
    this.AssertEquals("USDJPY", mql4.GetSymbol());
    
    delete mql4;
}


void MQL4Test::TestGetPoint(void)
{
    this.Init("TestGetPoint");
    
    mql4 = new MQL4();
    
    // デフォルトはチャートの通貨ペアのPointと同一
    this.AssertEquals(_Point, mql4.GetPoint());
    
    // SetSymbolメソッドで通貨ペアを変えるとその通貨ペアのPointとなる
    // このテストは通貨ペア名の後ろに文字がついている口座では失敗するので注意
    mql4.SetSymbol("USDJPY");
    this.AssertEquals(MarketInfo("USDJPY", MODE_POINT), mql4.GetPoint());
    mql4.SetSymbol("EURUSD");
    this.AssertEquals(MarketInfo("EURUSD", MODE_POINT), mql4.GetPoint());
    
    delete mql4;
}


void MQL4Test::TestGetDigits(void)
{
    this.Init("TestGetDigits");
    
    mql4 = new MQL4();
    
    // デフォルトはチャートの通貨ペアのDigitsと同一
    this.AssertEquals(_Digits, mql4.GetDigits());
    
    // SetSymbolメソッドで通貨ペアを変えるとその通貨ペアのDigitsとなる
    // このテストは通貨ペア名の後ろに文字がついている口座では失敗するので注意
    mql4.SetSymbol("USDJPY");
    this.AssertEquals((int)MarketInfo("USDJPY", MODE_DIGITS), mql4.GetDigits());
    mql4.SetSymbol("EURUSD");
    this.AssertEquals((int)MarketInfo("EURUSD", MODE_DIGITS), mql4.GetDigits());
    
    delete mql4;
}


void MQL4Test::TestGetTradeBar(void)
{
    this.Init("TestGetTradeBar");
    
    mql4 = new MQL4();
    
    // デフォルトはBars
    this.AssertEquals(Bars, mql4.GetTradeBar());
    
    // GetTradeBarメソッドを使用した場合はその値となる
    mql4.SetTradeBar(100);
    this.AssertEquals(100, mql4.GetTradeBar());
    
    delete mql4;
}


void MQL4Test::TestGetMult(void)
{
    this.Init("TestGetMult");
    
    mql4 = new MQL4();
    
    // 小数点以下3桁5桁口座用のテスト
    mql4.SetSymbol("USDJPY");
    this.AssertEquals(10, mql4.GetMult());
    mql4.SetSymbol("EURUSD");
    this.AssertEquals(10, mql4.GetMult());
    
    // 小数点以下2桁4桁口座用のテスト
    /* mql4.SetSymbol("USDJPY");
    this.AssertEquals(1, mql4.GetMult());
    mql4.SetSymbol("EURUSD");
    this.AssertEquals(1, mql4.GetMult()); */
    
    // EZインベスト証券USDJPY用のテスト
    /* mql4.SetSymbol("USDJPY");
    this.AssertEquals(100, mql4.GetMult()); */
    
    delete mql4;
}


void MQL4Test::TestGetIsTrade(void)
{
    this.Init("TestGetIsTrade");
    
    mql4 = new MQL4();
    
    // デフォルトはtrue
    this.AssertTrue(mql4.GetIsTrade());
    
    // SetFalseIsTradeを実行したあとはfalse
    mql4.SetFalseIsTrade();
    this.AssertFalse(mql4.GetIsTrade());
    
    delete mql4;
}


void MQL4Test::TestGetGMTShift(void)
{
    this.Init("TestGetGMTShift");
    
    mql4 = new MQL4();
    
    // デフォルトは2
    this.AssertEquals(2, mql4.GetGMTShift());
    
    // SetSymbolメソッドを使用した場合はその値となる
    mql4.SetGMTShift(0);
    this.AssertEquals(0, mql4.GetGMTShift());
    mql4.SetGMTShift(23);
    this.AssertEquals(23, mql4.GetGMTShift());
    
    // 0未満, 24以上は設定不可
    mql4.SetGMTShift(0);
    mql4.SetGMTShift(-1);
    this.AssertEquals(0, mql4.GetGMTShift());
    mql4.SetGMTShift(23);
    mql4.SetGMTShift(24);
    this.AssertEquals(23, mql4.GetGMTShift());
    
    delete mql4;
}


void MQL4Test::TestGetIsBuyTrade(void)
{
    this.Init("TestGetIsBuyTrade");
    
    mql4 = new MQL4();
    
    // デフォルトはtrue
    this.AssertTrue(mql4.GetIsSellTrade());
    
    // SetFalseIsBuyTradeを実行したあとはfalse
    mql4.SetFalseIsBuyTrade();
    this.AssertFalse(mql4.GetIsBuyTrade());
    
    delete mql4;
}


void MQL4Test::TestGetIsSellTrade(void)
{
    this.Init("TestGetIsSellTrade");
    
    mql4 = new MQL4();
    
    // デフォルトはtrue
    this.AssertTrue(mql4.GetIsSellTrade());
    
    // SetFalseIsSellTradeを実行したあとはfalse
    mql4.SetFalseIsSellTrade();
    this.AssertFalse(mql4.GetIsSellTrade());
    
    delete mql4;
}


MQL4Test *test;


int OnInit()
{
    test = new MQL4Test();

    test.TestGetSymbol();
    test.TestGetPoint();
    test.TestGetDigits();
    test.TestGetTradeBar();
    test.TestGetMult();
    test.TestGetIsTrade();
    test.TestGetGMTShift();
    test.TestGetIsBuyTrade();
    test.TestGetIsSellTrade();

    test.Result();

    return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
    delete test;
}


void OnTick()
{
    
}

