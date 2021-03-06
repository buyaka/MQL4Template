#property copyright "Copyright 2018, Keisuke Iwabuchi"
#property link      "https://www.mql5.com"
#property strict


/*
#define Provider(func, array1, array2) \
    \
    for (int i = 0; i < ArraySize(array1); i++) { \
        func(array1[i], array2[i]); \
    }
*/


class UnitTest
{
private:
    string test_name;
    int    test_count;
    int    test_case;
    int    passed;
    int    failed;
    int    tickets[];
    
    void Judge(const bool value, const string funcsig);
    void Passed(void);
    void Failed(const string funcsig);
    
    string FileGetString(const string file);
    
    void AddTicket(const int ticket);
    bool SelectByTicket(const int ticket);
    
    int MakeOrderType(void);
    double MakeLots(void);
    double MakePrice(const int type);
    double MakeStopLoss(const int type, const double price);
    double MakeTakeProfit(const int type, const double price);
    int MakeMagicNumber(void);

protected:
    int MakeOrder(
        string symbol,
        int type,
        double lots,
        double price,
        double sl,
        double tp,
        string comment = "",
        int magic = 0,
        datetime expiration = 0);
    void MakeRandomOrder(const int count = 1, int magic = -1);
    void MakeBuyOrder(const int count = 1, int magic = -1);
    void MakeSellOrder(const int count = 1, int magic = -1);
    void MakeBuyLimitOrder(const int count = 1, int magic = -1);
    void MakeSellLimitOrder(const int count = 1, int magic = -1);
    void MakeBuyStopOrder(const int count = 1, int magic = -1);
    void MakeSellStopOrder(const int count = 1, int magic = -1);
    void ResetOrder(void);

public:
    UnitTest(void);
    
    void Init(const string name = "");
    void Result(void);
    
    // value is ...
    template<typename T>
    void AssertEquals(const T value1, const T value2);
    template<typename T>
    void AssertGreaterThan(const T expect, const T value); // expect < value
    template<typename T>
    void AssertGreaterThanOrEqual(const T expect, const T value); // expect <= value
    template<typename T>
    void AssertLessThan(const T expect, const T value); // expect > value
    template<typename T>
    void AssertLessThanOrEqual(const T expect, const T value); // expect >= value
    
    // string is ...
    void AssertNull(const string value); // value == NULL
    void AssertStringStartsWith(const string value, const string prefix);
    void AssertStringEndsWith(const string value, const string suffix);
    
    // boolean is ...
    void AssertTrue(const bool value); // value is true
    void AssertFalse(const bool value); // value is false
    
    // array is ...
    template<typename T>
    void AssertContains(const T value, const T &array[]);
    template<typename T>
    void AssertCount(const int count, const T &array[]);
    
    // file is ...
    void AssertFileExists(const string file, const int flag = 0);
    void AssertFileEquals(const string file1, const string file2);
    
    // comment is ...
    void AssertSeeComment(const string value);
    void AssertDontSeeComment(const string value);
    
    // object is ...
    void AssertHasObject(const string value);
    void AssertObjectAttribute(
        const int value,
        const string name,
        const int property_id,
        const int modifier = 0);
    void AssertObjectAttribute(
        const double value,
        const string name,
        const int property_id,
        const int modifier = 0);
    void AssertObjectAttribute(
        const string value,
        const string name,
        const int property_id,
        const int modifier = 0);
    
    // order is ...
    void AssertOrderCount(const int count);
    void AssertHasOrderByTicket(const int ticket);
    void AssertHasOrderByMagicNumber(const int magic);
    void AssertSymbol(const int ticket, const string symbol);
    void AssertType(const int ticket, const int type);
    void AssertLots(const int ticket, const double lots);
    void AssertTP(const int ticket, const double tp);
    void AssertSL(const int ticket, const double sl);
    void AssertTPSL(const int ticket, const double tp, const double sl);
    void AssertComment(const int ticket, const string comment);
    void AssertMagicNumber(const int ticket, const int magic);
    void AssertExpiration(const int ticket, const datetime expiration);
};


// テストの判定処理
void UnitTest::Judge(const bool value, const string funcsig)
{
    if (value) {
        this.Passed();
    } else {
        this.Failed(funcsig);
    }
}


// テストケース成功時の処理
void UnitTest::Passed(void)
{
    this.test_case++;
    this.passed++;
}


// テストケース失敗時の処理
void UnitTest::Failed(const string funcsig)
{
    this.test_case++;
    this.failed++;
    Print(this.test_name, " : Test case ", this.test_case, " failed. ", funcsig);
}


// ファイル内の文章を取得する
string UnitTest::FileGetString(const string file)
{
    string result = "";
    int file_handle = FileOpen(file, FILE_READ|FILE_TXT|FILE_ANSI); 
  
    if (file_handle != INVALID_HANDLE) { 
        while (!FileIsEnding(file_handle)) {
            result += FileReadString(file_handle) + "\n";
        } 
        FileClose(file_handle);
    }
    return(result);
}


// テスト用オープンオーダーのチケット番号をメンバ変数ticketsへ登録する
void UnitTest::AddTicket(const int ticket)
{
    int new_size = ArraySize(this.tickets) + 1;
    ArrayResize(this.tickets, new_size);
    
    this.tickets[new_size - 1] = ticket;
}


// チケット番号ticketでOrderSelectする
bool UnitTest::SelectByTicket(const int ticket)
{
    return(OrderSelect(ticket, SELECT_BY_TICKET));
}


// ランダムな取引種別を作成する
int UnitTest::MakeOrderType(void)
{
    return(MathRand() % 6);
}


// ランダムなロット数を作成する
double UnitTest::MakeLots(void)
{
    double max = MarketInfo(Symbol(), MODE_MAXLOT);
    double min = MarketInfo(Symbol(), MODE_MINLOT);

    double lots = min + (max - min) * (1/ MathRand());

    return(NormalizeDouble(lots, 2));
}


// ランダムなエントリー価格を作成する
double UnitTest::MakePrice(const int type)
{
    int diff = (int)MathCeil(MathRand() / 300);
    if (diff < 10) {
        diff = 10;
    }
    
    if (type == OP_BUY) {
        return(Ask);
    } else if (type == OP_SELL) {
        return(Bid);
    } else if (type == OP_BUYLIMIT) {
        return(Ask - diff * _Point);
    } else if (type == OP_SELLLIMIT) {
        return(Bid + diff * _Point);
    } else if (type == OP_BUYSTOP) {
        return(Ask + diff * _Point);
    } else if (type == OP_SELLSTOP) {
        return(Bid - diff * _Point);
    }
    
    return(0);
}


// ランダムなSLを作成する
double UnitTest::MakeStopLoss(const int type, const double price)
{
    int diff = (int)MathCeil(MathRand() / 30);
    if (diff > 500) {
        diff = 0;
    }
    
    if (diff == 0) {
        return(0);
    }
    
    if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) {
        return(price - diff * _Point);
    }
    return(price + diff * _Point);
}


// ランダムなTPを作成する
double UnitTest::MakeTakeProfit(const int type, const double price)
{
    int diff = (int)MathCeil(MathRand() / 30);
    if (diff > 500) {
        diff = 0;
    }
    
    if (diff == 0) {
        return(0);
    }
    
    if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) {
        return(price + diff * _Point);
    }
    return(price - diff * _Point);
}


// ランダムな値のマジックナンバーを生成する
int UnitTest::MakeMagicNumber(void)
{
    int magic = MathRand();
    if (magic >= 10000) {
        magic = 0;
    }
    return(magic);
}


// テスト用のオープンオーダーを作成する
int UnitTest::MakeOrder(
    string symbol,
    int type,
    double lots,
    double price,
    double sl,
    double tp,
    string comment = "",
    int magic = 0,
    datetime expiration = 0)
{
    int ticket = OrderSend(symbol, type, lots, price, 100, sl, tp, comment, magic, expiration);
    
    this.AddTicket(ticket);
    
    return(ticket);
}


// テスト用にランダムなオープンオーダーをcount個作成する
void UnitTest::MakeRandomOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = this.MakeOrderType();
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_BUYオーダーをcount個作成する
void UnitTest::MakeBuyOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_BUY;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_SELLオーダーをcount個作成する
void UnitTest::MakeSellOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_SELL;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_BUYLIMITオーダーをcount個作成する
void UnitTest::MakeBuyLimitOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_BUYLIMIT;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_SELLLIMITオーダーをcount個作成する
void UnitTest::MakeSellLimitOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_SELLLIMIT;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_BUYSTOPオーダーをcount個作成する
void UnitTest::MakeBuyStopOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_BUYSTOP;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用にOP_SELLSTOPオーダーをcount個作成する
void UnitTest::MakeSellStopOrder(const int count = 1, int magic = -1)
{
    int ticket = 0;
    int type = OP_SELLSTOP;
    double lots = this.MakeLots();
    double price = this.MakePrice(type);
    double sl = this.MakeStopLoss(type, price);
    double tp = this.MakeTakeProfit(type, price);
    if (magic == -1) {
        magic = this.MakeMagicNumber();
    }
    
    for (int i = 0; i < count; i++) {
        ticket = OrderSend(Symbol(), type, lots, price, 100, sl, tp, "", magic);
        
        if (ticket != -1) {
            this.AddTicket(ticket);
        }
    }
}


// テスト用に作成したオープンオーダーを削除する
void UnitTest::ResetOrder(void)
{
    int size = ArraySize(this.tickets);
    bool result;
    for (int i = 0; i < size; i++) {
        if (OrderSelect(this.tickets[i], SELECT_BY_TICKET) == true) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                result = OrderClose(this.tickets[i], OrderLots(), OrderClosePrice(), 100);
            } else {
                result = OrderDelete(this.tickets[i]);
            }
        }
    }
    
    ArrayResize(this.tickets, 0);
}


UnitTest::UnitTest(void)
{
    this.test_count = 0;
    this.test_case = 0;
    this.passed = 0;
    this.failed = 0;
}


// 単体テストを初期化する
void UnitTest::Init(const string name = "")
{
    this.test_name = (StringLen(name) > 0) ? name : "UnitTest";
    this.test_count++;
    this.test_case = 0;
    this.ResetOrder();
}


// 単体テストを終了する
void UnitTest::Result(void)
{
    if (this.failed == 0) {
        PlaySound("news.wav");
        Print("OK (", this.test_count, " tests, ", this.passed, " assertions)");
    } else {
        PlaySound("stops.wav");
        Print("Tests: ", this.test_count, ", Assertions: ", (this.passed + this.failed), ", Failures: ", this.failed, ".");
        Print("FAILURES!");
    }
    this.ResetOrder();
}


// value is ...
// value1とvalue2が等しい
template<typename T>
void UnitTest::AssertEquals(const T value1,const T value2)
{
    this.Judge(value1 == value2, __FUNCSIG__);
}


// expectよりもvalueが大きい
template<typename T>
void UnitTest::AssertGreaterThan(const T expect, const T value)
{
    this.Judge(expect < value, __FUNCSIG__);
}


// expectよりもvalueが大きいもしくは等しい
template<typename T>
void UnitTest::AssertGreaterThanOrEqual(const T expect, const T value)
{
    this.Judge(expect <= value, __FUNCSIG__);
}


// expectよりもvalueが小さい
template<typename T>
void UnitTest::AssertLessThan(const T expect, const T value)
{
    this.Judge(expect > value, __FUNCSIG__);
}


// expectよりもvalueが小さいもしくは等しい
template<typename T>
void UnitTest::AssertLessThanOrEqual(const T expect, const T value)
{
    this.Judge(expect >= value, __FUNCSIG__);
}


// string is ...
// valueがNULLであることをアサート
// 空文字""もエラーとなる
void UnitTest::AssertNull(const string value)
{
    this.Judge(value == NULL, __FUNCSIG__);
}


// valueがprefixで始まっていない場合にエラー
void UnitTest::AssertStringStartsWith(const string value, const string prefix)
{
    this.Judge(StringSubstr(value, 0, StringLen(prefix)) == prefix, __FUNCSIG__);
}


// value がsuffixで終わっていない場合にエラー
void UnitTest::AssertStringEndsWith(const string value,const string suffix)
{
    this.Judge(
        StringSubstr(value, StringLen(value) - StringLen(suffix), StringLen(suffix)) == suffix,
        __FUNCSIG__
    );
}


// boolean is ...
// valueがtrueである
void UnitTest::AssertTrue(const bool value)
{
    this.Judge(value == true, __FUNCSIG__);
}


// valueがfalseである
void UnitTest::AssertFalse(const bool value)
{
    this.Judge(value == false, __FUNCSIG__);
}


// array is ...
// 配列arrayの値valueが含まれている
template<typename T>
void UnitTest::AssertContains(const T value, const T &array[])
{
    int size = ArraySize(array);
    for (int i = 0; i < size; i++) {
        if (array[i] == value) {
            this.Passed();
            return;
        }
    }
    
    this.Failed(__FUNCSIG__);
}


// 配列arrayの値の数がcountである
template<typename T>
void UnitTest::AssertCount(const int count, const T &array[])
{
    this.Judge(ArraySize(array) == count, __FUNCSIG__);
}


// file is ...
// Filesフォルダ内にfileが存在する。
// 共通フォルダ Terminal/Common/Files内に存在するかを確認するにはflagにFILE_COMMONを指定する
void UnitTest::AssertFileExists(const string file, const int flag = 0)
{
    this.Judge(FileIsExist(file, flag), __FUNCSIG__);
}


// file1とfile2の内容が等しい
void UnitTest::AssertFileEquals(const string file1, const string file2)
{
    string file_str1 = this.FileGetString(file1);
    string file_str2 = this.FileGetString(file2);
    
    this.Judge(file_str1 == file_str2, __FUNCSIG__);
}


// comment is ...
// Commentによる表示にvalueが含まれている
void UnitTest::AssertSeeComment(const string value)
{
    this.Judge(StringFind(ChartGetString(0, CHART_COMMENT), value, 0) >= 0, __FUNCSIG__);
}


// Commentによる表示にvalueを含んでいない
void UnitTest::AssertDontSeeComment(const string value)
{
    this.Judge(StringFind(ChartGetString(0, CHART_COMMENT), value, 0) == -1, __FUNCSIG__);
}


// object is ...
// valueという名称のオブジェクトが存在する
void UnitTest::AssertHasObject(const string value)
{
    this.Judge(ObjectFind(0, value) >= 0, __FUNCSIG__);
}


// nameという名称のオブジェクトのプロパティがvalueと一致する
void UnitTest::AssertObjectAttribute(
    const int value,
    const string name,
    const int property_id,
    const int modifier = 0)
{
    this.Judge(ObjectGetInteger(0, name, property_id, modifier) == value, __FUNCSIG__);
}


void UnitTest::AssertObjectAttribute(
    const double value,
    const string name,
    const int property_id,
    const int modifier = 0)
{
    this.Judge(ObjectGetDouble(0, name, property_id, modifier) == value, __FUNCSIG__);
}


void UnitTest::AssertObjectAttribute(
    const string value,
    const string name,
    const int property_id,
    const int modifier = 0)
{
    this.Judge(ObjectGetString(0, name, property_id, modifier) == value, __FUNCSIG__);
}


// open order is ...
// オーダーの件数がcountと一致する
// 他EA, 手動取引の影響を受けるので使用時は注意すること
void UnitTest::AssertOrderCount(const int count)
{
    this.Judge(OrdersTotal() == count, __FUNCSIG__);
}


// チケット番号ticketのオーダーが存在すること
// トレーディングプール, ヒストリープールは判別していないので注意すること
void UnitTest::AssertHasOrderByTicket(const int ticket)
{
    this.Judge(OrderSelect(ticket, SELECT_BY_TICKET), __FUNCSIG__);
}


// マジックナンバーmagicのオーダーがトレーディングプールに存在すること
void UnitTest::AssertHasOrderByMagicNumber(const int magic)
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) == false) {
            break;
        }
        if (OrderMagicNumber() == magic) {
            this.Passed();
            return;
        }
    }
    this.Failed(__FUNCSIG__);
}


// チケット番号ticketのオーダーの通貨ペアがsymbolと一致する
void UnitTest::AssertSymbol(const int ticket, const string symbol)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderSymbol() == symbol, __FUNCSIG__);
}


// チケット番号ticketのオーダーの取引種別がtypeと一致する
void UnitTest::AssertType(const int ticket, const int type)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderType() == type, __FUNCSIG__);
}


// チケット番号ticketのオーダーのロット数がlotsと一致する
void UnitTest::AssertLots(const int ticket, const double lots)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderLots() == lots, __FUNCSIG__);
}


// チケット番号ticketのオーダーのTPがtpと一致する
void UnitTest::AssertTP(const int ticket, const double tp)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderTakeProfit() == tp, __FUNCSIG__);
}


// チケット番号ticketのオーダーのSLがslと一致する
void UnitTest::AssertSL(const int ticket, const double sl)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderStopLoss() == sl, __FUNCSIG__);
}


// チケット番号ticketのオーダーがTP/SLがtpとslに一致する
// テストケース2件分なので注意
void UnitTest::AssertTPSL(const int ticket,const double tp,const double sl)
{
    this.AssertTP(ticket, tp);
    this.AssertSL(ticket, sl);
}


// チケット番号ticketのオーダーのコメントがcommentと一致する
// コメントは業者によって文字を付与される可能性もあるので注意
void UnitTest::AssertComment(const int ticket, const string comment)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderComment() == comment, __FUNCSIG__);
}


// チケット番号ticketのオーダーのマジックナンバーがmagicと一致する
void UnitTest::AssertMagicNumber(const int ticket, const int magic)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    
    this.Judge(OrderMagicNumber() == magic, __FUNCSIG__);
}


// チケット番号ticketのオーダーの有効期限がexpirationと一致する
void UnitTest::AssertExpiration(const int ticket, const datetime expiration)
{
    if (this.SelectByTicket(ticket) == false) {
        this.Failed(__FUNCSIG__);
        return;
    }
    Print(OrderExpiration(), " ", expiration);
    this.Judge(OrderExpiration() == expiration, __FUNCSIG__);
}
