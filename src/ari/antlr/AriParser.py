# encoding: utf-8
from antlr4 import *
from io import StringIO
import sys
if sys.version_info[1] > 5:
	from typing import TextIO
else:
	from typing.io import TextIO

def serializedATN():
    return [
        4,1,11,42,2,0,7,0,2,1,7,1,2,2,7,2,1,0,1,0,1,0,5,0,10,8,0,10,0,12,
        0,13,9,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,24,8,1,1,2,1,2,
        1,2,3,2,29,8,2,1,2,1,2,1,2,1,2,1,2,1,2,5,2,37,8,2,10,2,12,2,40,9,
        2,1,2,0,1,4,3,0,2,4,0,0,43,0,11,1,0,0,0,2,23,1,0,0,0,4,28,1,0,0,
        0,6,7,3,2,1,0,7,8,5,1,0,0,8,10,1,0,0,0,9,6,1,0,0,0,10,13,1,0,0,0,
        11,9,1,0,0,0,11,12,1,0,0,0,12,1,1,0,0,0,13,11,1,0,0,0,14,15,5,2,
        0,0,15,16,5,3,0,0,16,17,3,4,2,0,17,18,5,4,0,0,18,24,1,0,0,0,19,20,
        5,5,0,0,20,21,5,9,0,0,21,22,5,6,0,0,22,24,3,4,2,0,23,14,1,0,0,0,
        23,19,1,0,0,0,24,3,1,0,0,0,25,26,6,2,-1,0,26,29,5,10,0,0,27,29,5,
        9,0,0,28,25,1,0,0,0,28,27,1,0,0,0,29,38,1,0,0,0,30,31,10,2,0,0,31,
        32,5,7,0,0,32,37,3,4,2,3,33,34,10,1,0,0,34,35,5,8,0,0,35,37,3,4,
        2,2,36,30,1,0,0,0,36,33,1,0,0,0,37,40,1,0,0,0,38,36,1,0,0,0,38,39,
        1,0,0,0,39,5,1,0,0,0,40,38,1,0,0,0,5,11,23,28,36,38
    ]

class AriParser ( Parser ):

    grammarFileName = "Ari.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "';'", "'print'", "'('", "')'", "'set'", 
                     "':='", "'+'", "'-'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "VAR", "INT", "WS" ]

    RULE_prog = 0
    RULE_stmt = 1
    RULE_expr = 2

    ruleNames =  [ "prog", "stmt", "expr" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    T__6=7
    T__7=8
    VAR=9
    INT=10
    WS=11

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.13.1")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class ProgContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._stmt = None # StmtContext
            self.s = list() # of StmtContexts

        def stmt(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(AriParser.StmtContext)
            else:
                return self.getTypedRuleContext(AriParser.StmtContext,i)


        def getRuleIndex(self):
            return AriParser.RULE_prog




    def prog(self):

        localctx = AriParser.ProgContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_prog)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 11
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==2 or _la==5:
                self.state = 6
                localctx._stmt = self.stmt()
                localctx.s.append(localctx._stmt)
                self.state = 7
                self.match(AriParser.T__0)
                self.state = 13
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class StmtContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return AriParser.RULE_stmt

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class PrintContext(StmtContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.StmtContext
            super().__init__(parser)
            self.e = None # ExprContext
            self.copyFrom(ctx)

        def expr(self):
            return self.getTypedRuleContext(AriParser.ExprContext,0)



    class AssignContext(StmtContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.StmtContext
            super().__init__(parser)
            self.v = None # Token
            self.e = None # ExprContext
            self.copyFrom(ctx)

        def VAR(self):
            return self.getToken(AriParser.VAR, 0)
        def expr(self):
            return self.getTypedRuleContext(AriParser.ExprContext,0)




    def stmt(self):

        localctx = AriParser.StmtContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_stmt)
        try:
            self.state = 23
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [2]:
                localctx = AriParser.PrintContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 14
                self.match(AriParser.T__1)
                self.state = 15
                self.match(AriParser.T__2)
                self.state = 16
                localctx.e = self.expr(0)
                self.state = 17
                self.match(AriParser.T__3)
                pass
            elif token in [5]:
                localctx = AriParser.AssignContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 19
                self.match(AriParser.T__4)
                self.state = 20
                localctx.v = self.match(AriParser.VAR)
                self.state = 21
                self.match(AriParser.T__5)
                self.state = 22
                localctx.e = self.expr(0)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ExprContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return AriParser.RULE_expr

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)


    class AddContext(ExprContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.ExprContext
            super().__init__(parser)
            self.e1 = None # ExprContext
            self.e2 = None # ExprContext
            self.copyFrom(ctx)

        def expr(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(AriParser.ExprContext)
            else:
                return self.getTypedRuleContext(AriParser.ExprContext,i)



    class SubContext(ExprContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.ExprContext
            super().__init__(parser)
            self.e1 = None # ExprContext
            self.e2 = None # ExprContext
            self.copyFrom(ctx)

        def expr(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(AriParser.ExprContext)
            else:
                return self.getTypedRuleContext(AriParser.ExprContext,i)



    class VarContext(ExprContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.ExprContext
            super().__init__(parser)
            self.v = None # Token
            self.copyFrom(ctx)

        def VAR(self):
            return self.getToken(AriParser.VAR, 0)


    class ConstContext(ExprContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a AriParser.ExprContext
            super().__init__(parser)
            self.n = None # Token
            self.copyFrom(ctx)

        def INT(self):
            return self.getToken(AriParser.INT, 0)



    def expr(self, _p:int=0):
        _parentctx = self._ctx
        _parentState = self.state
        localctx = AriParser.ExprContext(self, self._ctx, _parentState)
        _prevctx = localctx
        _startState = 4
        self.enterRecursionRule(localctx, 4, self.RULE_expr, _p)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 28
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [10]:
                localctx = AriParser.ConstContext(self, localctx)
                self._ctx = localctx
                _prevctx = localctx

                self.state = 26
                localctx.n = self.match(AriParser.INT)
                pass
            elif token in [9]:
                localctx = AriParser.VarContext(self, localctx)
                self._ctx = localctx
                _prevctx = localctx
                self.state = 27
                localctx.v = self.match(AriParser.VAR)
                pass
            else:
                raise NoViableAltException(self)

            self._ctx.stop = self._input.LT(-1)
            self.state = 38
            self._errHandler.sync(self)
            _alt = self._interp.adaptivePredict(self._input,4,self._ctx)
            while _alt!=2 and _alt!=ATN.INVALID_ALT_NUMBER:
                if _alt==1:
                    if self._parseListeners is not None:
                        self.triggerExitRuleEvent()
                    _prevctx = localctx
                    self.state = 36
                    self._errHandler.sync(self)
                    la_ = self._interp.adaptivePredict(self._input,3,self._ctx)
                    if la_ == 1:
                        localctx = AriParser.AddContext(self, AriParser.ExprContext(self, _parentctx, _parentState))
                        localctx.e1 = _prevctx
                        self.pushNewRecursionContext(localctx, _startState, self.RULE_expr)
                        self.state = 30
                        if not self.precpred(self._ctx, 2):
                            from antlr4.error.Errors import FailedPredicateException
                            raise FailedPredicateException(self, "self.precpred(self._ctx, 2)")
                        self.state = 31
                        self.match(AriParser.T__6)
                        self.state = 32
                        localctx.e2 = self.expr(3)
                        pass

                    elif la_ == 2:
                        localctx = AriParser.SubContext(self, AriParser.ExprContext(self, _parentctx, _parentState))
                        localctx.e1 = _prevctx
                        self.pushNewRecursionContext(localctx, _startState, self.RULE_expr)
                        self.state = 33
                        if not self.precpred(self._ctx, 1):
                            from antlr4.error.Errors import FailedPredicateException
                            raise FailedPredicateException(self, "self.precpred(self._ctx, 1)")
                        self.state = 34
                        self.match(AriParser.T__7)
                        self.state = 35
                        localctx.e2 = self.expr(2)
                        pass

             
                self.state = 40
                self._errHandler.sync(self)
                _alt = self._interp.adaptivePredict(self._input,4,self._ctx)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.unrollRecursionContexts(_parentctx)
        return localctx



    def sempred(self, localctx:RuleContext, ruleIndex:int, predIndex:int):
        if self._predicates == None:
            self._predicates = dict()
        self._predicates[2] = self.expr_sempred
        pred = self._predicates.get(ruleIndex, None)
        if pred is None:
            raise Exception("No predicate with index:" + str(ruleIndex))
        else:
            return pred(localctx, predIndex)

    def expr_sempred(self, localctx:ExprContext, predIndex:int):
            if predIndex == 0:
                return self.precpred(self._ctx, 2)
         

            if predIndex == 1:
                return self.precpred(self._ctx, 1)
         




