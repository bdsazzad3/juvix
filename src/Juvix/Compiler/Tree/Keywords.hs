module Juvix.Compiler.Tree.Keywords
  ( module Juvix.Compiler.Tree.Keywords,
    module Juvix.Compiler.Tree.Keywords.Base,
    module Juvix.Data.Keyword.All,
  )
where

import Juvix.Compiler.Tree.Keywords.Base
import Juvix.Data.Keyword.All
  ( kwAdd_,
    kwAlloc,
    kwAnomaActionDelta,
    kwAnomaActionsDelta,
    kwAnomaAddDelta,
    kwAnomaByteArrayFromAnomaContents,
    kwAnomaByteArrayToAnomaContents,
    kwAnomaDecode,
    kwAnomaEncode,
    kwAnomaGet,
    kwAnomaProveAction,
    kwAnomaProveDelta,
    kwAnomaResourceCommitment,
    kwAnomaResourceDelta,
    kwAnomaResourceKind,
    kwAnomaResourceNullifier,
    kwAnomaSha256,
    kwAnomaSign,
    kwAnomaSignDetached,
    kwAnomaSubDelta,
    kwAnomaVerifyDetached,
    kwAnomaVerifyWithMessage,
    kwAnomaZeroDelta,
    kwArgsNum,
    kwAssert,
    kwAtoi,
    kwBr,
    kwByteArrayFromListUInt8,
    kwByteArrayLength,
    kwCAlloc,
    kwCCall,
    kwCExtend,
    kwCall,
    kwCase,
    kwDiv_,
    kwEcOp,
    kwEq_,
    kwFail,
    kwFieldAdd,
    kwFieldDiv,
    kwFieldMul,
    kwFieldSub,
    kwFieldToInt,
    kwIntToField,
    kwIntToUInt8,
    kwLe_,
    kwLt_,
    kwMod_,
    kwMul_,
    kwPoseidon,
    kwRandomEcPoint,
    kwSave,
    kwSeq_,
    kwShow,
    kwStrcat,
    kwSub_,
    kwTrace,
    kwUInt8ToInt,
  )
import Juvix.Prelude

allKeywordStrings :: HashSet Text
allKeywordStrings = keywordsStrings allKeywords

allKeywords :: [Keyword]
allKeywords =
  baseKeywords
    ++ [ kwAdd_,
         kwSub_,
         kwMul_,
         kwDiv_,
         kwLt_,
         kwLe_,
         kwFieldAdd,
         kwFieldSub,
         kwFieldMul,
         kwFieldDiv,
         kwSeq_,
         kwEq_,
         kwStrcat,
         kwShow,
         kwAtoi,
         kwAssert,
         kwTrace,
         kwFail,
         kwArgsNum,
         kwAlloc,
         kwCAlloc,
         kwCExtend,
         kwCall,
         kwCCall,
         kwBr,
         kwCase,
         kwSave,
         kwAnomaGet,
         kwAnomaDecode,
         kwAnomaEncode,
         kwAnomaVerifyDetached,
         kwAnomaSign,
         kwAnomaSignDetached,
         kwAnomaVerifyWithMessage,
         kwAnomaByteArrayFromAnomaContents,
         kwAnomaByteArrayToAnomaContents,
         kwPoseidon,
         kwEcOp,
         kwRandomEcPoint,
         kwByteArrayLength,
         kwByteArrayFromListUInt8,
         kwIntToUInt8,
         kwUInt8ToInt,
         kwIntToField,
         kwFieldToInt
       ]
